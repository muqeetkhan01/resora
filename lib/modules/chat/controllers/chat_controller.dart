import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/chat_session_service.dart';
import '../../../core/services/resora_ai_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

enum _ChatRiskLevel {
  low,
  medium,
  high,
}

extension _ChatRiskLevelLabel on _ChatRiskLevel {
  String get label => switch (this) {
        _ChatRiskLevel.low => 'low',
        _ChatRiskLevel.medium => 'medium',
        _ChatRiskLevel.high => 'high',
      };
}

class _ChatSafetyAssessment {
  const _ChatSafetyAssessment({
    required this.riskLevel,
    this.emergencyMode = false,
    this.unsafeRequest = false,
  });

  final _ChatRiskLevel riskLevel;
  final bool emergencyMode;
  final bool unsafeRequest;
}

class ChatController extends GetxController {
  ChatController({
    ResoraAiService? aiService,
    ChatSessionService? chatSessionService,
  })  : _aiService = aiService ?? ResoraAiService(),
        _chatSessionService = chatSessionService ?? ChatSessionService();

  final ResoraAiService _aiService;
  final ChatSessionService _chatSessionService;
  final _session = Get.find<AppSessionController>();

  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();
  final scrollController = ScrollController();
  final messages = <ChatMessageModel>[].obs;
  final isTyping = false.obs;
  final draftText = ''.obs;
  final isSendCooldownActive = false.obs;
  final isDailyLimitReached = false.obs;
  final dailyLimitResetAt = Rxn<DateTime>();

  int _pendingReplies = 0;
  String? _activeSessionId;
  Timer? _sendCooldownTimer;
  Timer? _sessionInactivityTimer;
  Timer? _dailyLimitResetTimer;
  Worker? _premiumWorker;
  bool _isClosingSession = false;
  int _guestFreeSendCount = 0;
  DateTime? _guestWindowStartedAt;

  static const int maxCharacters = 500;
  static const int warningCharacters = 450;
  static const Duration sendCooldown = Duration(seconds: 2);
  static const List<String> rotatingLines = [
    "What's on your mind?",
    'Something on your mind?',
    'Ready when you are.',
    'This is your space.',
    'Start anywhere.',
    'No wrong way to begin.',
    "What's weighing on you?",
    'Take your time.',
  ];
  static const List<String> quickStartActions = [
    "I'm overwhelmed",
    'I need clarity',
    'I need to vent',
  ];

  final Random _random = Random();
  late final String sessionLine =
      rotatingLines[_random.nextInt(rotatingLines.length)];

  bool get canSend =>
      draftText.value.trim().isNotEmpty &&
      !isSendCooldownActive.value &&
      !isTyping.value &&
      draftText.value.characters.length <= maxCharacters;
  bool get hasPremiumAccess =>
      Get.isRegistered<SubscriptionService>() &&
      Get.find<SubscriptionService>().isPremium.value;
  int get characterCount => draftText.value.characters.length;
  bool get shouldShowCharacterWarning => characterCount >= warningCharacters;

  void dismissKeyboard() {
    inputFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  @override
  void onInit() {
    super.onInit();
    inputController.addListener(_handleDraftChanged);
    inputFocusNode.addListener(_handleInputFocusChanged);
    if (Get.isRegistered<SubscriptionService>()) {
      _premiumWorker = ever<bool>(
        Get.find<SubscriptionService>().isPremium,
        (_) => _refreshDailyAllowance(),
      );
    }
    _refreshDailyAllowance();
    _bootstrapSessionHistory();
  }

  Future<void> sendMessage([String? preset]) async {
    final text = (preset ?? inputController.text).trim();
    dismissKeyboard();
    if (text.isEmpty || isSendCooldownActive.value || isTyping.value) return;
    if (text.characters.length > maxCharacters) {
      _appendCharacterLimitMessage();
      _scrollToBottom();
      return;
    }

    final safetyAssessment = _assessSafety(text);
    if (safetyAssessment.emergencyMode || safetyAssessment.unsafeRequest) {
      _startSendCooldown();
      final reply = safetyAssessment.emergencyMode
          ? _emergencyModeReply
          : _unsafeRequestReply;
      await _appendAndPersistLocalExchange(
        userText: text,
        assistantText: reply,
        safetyAssessment: safetyAssessment,
      );
      return;
    }

    if (!hasPremiumAccess && isDailyLimitReached.value) {
      _appendDailyLimitMessage();
      _scrollToBottom();
      return;
    }

    _startSendCooldown();
    FreeChatAllowance? allowance;
    if (!hasPremiumAccess) {
      try {
        allowance = await _reserveDailyAllowance();
      } catch (_) {
        return;
      }
      if (!allowance.allowed) {
        _applyAllowance(allowance);
        _appendDailyLimitMessage();
        _scrollToBottom();
        return;
      }
    }

    final planType = hasPremiumAccess ? 'premium' : 'free';
    final dailyMessageCount = hasPremiumAccess || allowance == null
        ? null
        : ChatSessionService.freeChatMessageLimit - allowance.remaining;
    messages.add(ChatMessageModel(text: text, isUser: true, time: 'Now'));
    inputController.clear();
    _pendingReplies += 1;
    isTyping.value = true;
    _scrollToBottom();

    try {
      final uid = _session.firebaseUser?.uid;
      List<ChatMessageModel> contextWindow = messages.toList();
      var softMemoryBlock = '';

      if (uid != null) {
        final sessionId = await _chatSessionService.ensureActiveSession(uid);
        _activeSessionId = sessionId;
        softMemoryBlock = await _chatSessionService.buildSoftMemoryBlock(
          uid: uid,
          displayName: _session.displayName,
        );
        await _chatSessionService.saveMessage(
          uid: uid,
          sessionId: sessionId,
          isUser: true,
          text: text,
          planType: planType,
          dailyMessageCount: dailyMessageCount,
          riskLevel: safetyAssessment.riskLevel.label,
          emergencyMode: safetyAssessment.emergencyMode,
          unsafeRequest: safetyAssessment.unsafeRequest,
        );
        await _chatSessionService.touchSession(uid, sessionId);
        _restartSessionInactivityTimer();
        contextWindow = await _chatSessionService.loadRecentMessages(
          uid: uid,
          sessionId: sessionId,
          limit: 10,
        );
      }

      final reply = await _aiService.generateReply(
        messages: contextWindow,
        userName: _session.displayName,
        latestUserMessage: text,
        softMemoryBlock: softMemoryBlock,
      );
      messages.add(
        ChatMessageModel(
          text: reply,
          isUser: false,
          time: 'Now',
        ),
      );

      if (uid != null && _activeSessionId != null) {
        await _chatSessionService.saveMessage(
          uid: uid,
          sessionId: _activeSessionId!,
          isUser: false,
          text: reply,
          planType: planType,
          dailyMessageCount: dailyMessageCount,
          riskLevel: safetyAssessment.riskLevel.label,
          emergencyMode: safetyAssessment.emergencyMode,
          unsafeRequest: safetyAssessment.unsafeRequest,
        );
        await _chatSessionService.touchSession(uid, _activeSessionId!);
        _restartSessionInactivityTimer();
      }
    } catch (error) {
      messages.add(
        ChatMessageModel(
          text: _friendlyError(error),
          isUser: false,
          time: 'Now',
        ),
      );
    } finally {
      _pendingReplies = (_pendingReplies - 1).clamp(0, 999);
      isTyping.value = _pendingReplies > 0;
      if (allowance?.remaining == 0) {
        _applyAllowance(allowance!);
        _appendDailyLimitMessage();
      }
      _scrollToBottom();
    }
  }

  void openMembership() {
    Get.toNamed(AppRoutes.subscription);
  }

  Future<FreeChatAllowance> _reserveDailyAllowance() async {
    final uid = _session.firebaseUser?.uid;
    if (uid != null) {
      return _chatSessionService.reserveFreeChatMessage(uid);
    }

    final now = DateTime.now();
    final start = _guestWindowStartedAt;
    if (start == null ||
        now.difference(start) >= ChatSessionService.freeChatWindow) {
      _guestWindowStartedAt = now;
      _guestFreeSendCount = 0;
    }
    if (_guestFreeSendCount >= ChatSessionService.freeChatMessageLimit) {
      return FreeChatAllowance(
        allowed: false,
        remaining: 0,
        resetAt: _guestWindowStartedAt!.add(
          ChatSessionService.freeChatWindow,
        ),
      );
    }

    _guestFreeSendCount += 1;
    return FreeChatAllowance(
      allowed: true,
      remaining: ChatSessionService.freeChatMessageLimit - _guestFreeSendCount,
      resetAt: _guestWindowStartedAt!.add(
        ChatSessionService.freeChatWindow,
      ),
    );
  }

  Future<void> _refreshDailyAllowance() async {
    if (hasPremiumAccess) {
      isDailyLimitReached.value = false;
      dailyLimitResetAt.value = null;
      _dailyLimitResetTimer?.cancel();
      return;
    }

    final uid = _session.firebaseUser?.uid;
    if (uid == null) return;
    try {
      final allowance = await _chatSessionService.loadFreeChatAllowance(uid);
      if (!isClosed) _applyAllowance(allowance);
    } catch (_) {
      // Keep the current local state if allowance refresh fails.
    }
  }

  void _applyAllowance(FreeChatAllowance allowance) {
    isDailyLimitReached.value = allowance.remaining == 0;
    dailyLimitResetAt.value = allowance.resetAt;
    _dailyLimitResetTimer?.cancel();
    final delay = allowance.resetAt.difference(DateTime.now());
    if (delay > Duration.zero) {
      _dailyLimitResetTimer = Timer(delay, _refreshDailyAllowance);
    }
  }

  void _appendDailyLimitMessage() {
    const text =
        'You’ve reached today’s free chat limit. Upgrade to Premium to keep talking with Resora today.';
    if (messages.any((message) => !message.isUser && message.text == text)) {
      return;
    }
    messages.add(
      const ChatMessageModel(text: text, isUser: false, time: 'Now'),
    );
  }

  void _appendCharacterLimitMessage() {
    const text =
        'That message is a little long. Try sending the main part first so Resora can help.';
    if (messages.any((message) => !message.isUser && message.text == text)) {
      return;
    }
    messages.add(
      const ChatMessageModel(text: text, isUser: false, time: 'Now'),
    );
  }

  Future<void> _appendAndPersistLocalExchange({
    required String userText,
    required String assistantText,
    required _ChatSafetyAssessment safetyAssessment,
  }) async {
    messages.add(ChatMessageModel(text: userText, isUser: true, time: 'Now'));
    inputController.clear();
    messages.add(
      ChatMessageModel(text: assistantText, isUser: false, time: 'Now'),
    );
    _scrollToBottom();

    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      final sessionId = await _chatSessionService.ensureActiveSession(uid);
      _activeSessionId = sessionId;
      final planType = hasPremiumAccess ? 'premium' : 'free';
      await _chatSessionService.saveMessage(
        uid: uid,
        sessionId: sessionId,
        isUser: true,
        text: userText,
        planType: planType,
        riskLevel: safetyAssessment.riskLevel.label,
        emergencyMode: safetyAssessment.emergencyMode,
        unsafeRequest: safetyAssessment.unsafeRequest,
      );
      await _chatSessionService.saveMessage(
        uid: uid,
        sessionId: sessionId,
        isUser: false,
        text: assistantText,
        planType: planType,
        riskLevel: safetyAssessment.riskLevel.label,
        emergencyMode: safetyAssessment.emergencyMode,
        unsafeRequest: safetyAssessment.unsafeRequest,
      );
      await _chatSessionService.touchSession(uid, sessionId);
      _restartSessionInactivityTimer();
    } catch (_) {
      // Local safety responses should still display even if logging fails.
    }
  }

  void _handleDraftChanged() {
    draftText.value = inputController.text;
  }

  void _handleInputFocusChanged() {
    if (!inputFocusNode.hasFocus) {
      return;
    }

    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 320), _scrollToBottom);
  }

  Future<void> _bootstrapSessionHistory() async {
    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      final sessionId = await _chatSessionService.ensureActiveSession(uid);
      _activeSessionId = sessionId;
      final recent = await _chatSessionService.loadRecentMessages(
        uid: uid,
        sessionId: sessionId,
        limit: 10,
      );
      if (isClosed) {
        return;
      }
      messages.assignAll(recent);
      _scrollToBottom();
      _restartSessionInactivityTimer();
    } catch (_) {
      // Keep chat available even if persistence fails.
    }
  }

  void _startSendCooldown() {
    isSendCooldownActive.value = true;
    _sendCooldownTimer?.cancel();
    _sendCooldownTimer = Timer(sendCooldown, () {
      isSendCooldownActive.value = false;
    });
  }

  void _restartSessionInactivityTimer() {
    _sessionInactivityTimer?.cancel();
    _sessionInactivityTimer =
        Timer(ChatSessionService.sessionTimeout, _handleSessionTimeout);
  }

  Future<void> _handleSessionTimeout() async {
    await _closeSessionAndUpdateMemory(reason: 'inactivity');
    if (!isClosed) {
      messages.clear();
    }
  }

  Future<void> _closeSessionAndUpdateMemory({
    required String reason,
  }) async {
    if (_isClosingSession) {
      return;
    }

    final uid = _session.firebaseUser?.uid;
    final sessionId = _activeSessionId;
    if (uid == null || sessionId == null || sessionId.trim().isEmpty) {
      return;
    }

    _isClosingSession = true;
    try {
      final transcript = await _chatSessionService.loadSessionTranscript(
        uid: uid,
        sessionId: sessionId,
      );
      final existingMemory = await _chatSessionService.loadMemoryProfile(uid);
      final updates = await _aiService.updateMemoryFromTranscript(
        existingMemory: existingMemory,
        transcript: transcript,
      );
      await _chatSessionService.updateMemoryProfile(uid: uid, updates: updates);
      await _chatSessionService.closeSession(
        uid: uid,
        sessionId: sessionId,
        reason: reason,
      );
      _activeSessionId = null;
    } catch (_) {
      // Session close and memory update are best effort.
    } finally {
      _isClosingSession = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      // This controller can be attached to both the dashboard tab chat and
      // the pushed chat route at the same time. Scroll each attached position
      // directly to avoid `position` single-client assertion.
      for (final position in scrollController.positions.toList()) {
        position.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  _ChatSafetyAssessment _assessSafety(String text) {
    final current = _normalizeSafetyText(text);
    final recentUserText = messages
        .where((message) => message.isUser)
        .map((message) => message.text)
        .toList()
        .reversed
        .take(10)
        .join(' ');
    final combined = _normalizeSafetyText('$recentUserText $text');

    final unsafeRequest = _hasUnsafeRequestMeaning(current);
    final highRisk = _hasHighRiskMeaning(current) ||
        _hasHighRiskMeaning(combined) ||
        _hasEscalatedMeaning(current, combined);
    if (highRisk) {
      return _ChatSafetyAssessment(
        riskLevel: _ChatRiskLevel.high,
        emergencyMode: true,
        unsafeRequest: unsafeRequest,
      );
    }

    if (unsafeRequest) {
      return const _ChatSafetyAssessment(
        riskLevel: _ChatRiskLevel.medium,
        unsafeRequest: true,
      );
    }

    if (_hasMediumRiskMeaning(current) || _hasMediumRiskMeaning(combined)) {
      return const _ChatSafetyAssessment(riskLevel: _ChatRiskLevel.medium);
    }

    return const _ChatSafetyAssessment(riskLevel: _ChatRiskLevel.low);
  }

  String _normalizeSafetyText(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll(RegExp(r"[^\w\s']+"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _hasHighRiskMeaning(String text) {
    if (text.isEmpty) {
      return false;
    }

    const highRiskPhrases = <String>[
      'suicide',
      'kill myself',
      'killing myself',
      'end my life',
      'ending my life',
      'want to die',
      'wanna die',
      'wanting to die',
      'i want to be dead',
      "i don't want to be alive",
      'i dont want to be alive',
      "i don't want to be here",
      'i dont want to be here',
      'everyone would be better without me',
      'hurt myself',
      'harm myself',
      'self harm',
      'selfharm',
      'cut myself',
      'overdose',
      'i overdosed',
      'took too many pills',
      'cant breathe',
      "can't breathe",
      'cannot breathe',
      'trouble breathing',
      'choking',
      'is choking',
      'bleeding badly',
      'serious injury',
      'has a weapon',
      'he has a weapon',
      'she has a weapon',
      'they have a weapon',
      'won’t let me leave',
      "won't let me leave",
      'wont let me leave',
      'blocked the door',
      'trapped',
      'being trapped',
      'cannot keep myself safe',
      "can't keep myself safe",
      'cant keep myself safe',
      'cannot keep my child safe',
      "can't keep my child safe",
      'cant keep my child safe',
      'cannot keep them safe',
      "can't keep them safe",
      'cant keep them safe',
      'scared of what i’ll do',
      "scared of what i'll do",
      'scared of what i will do',
      'going to hurt him',
      'going to hurt her',
      'going to hurt them',
      'going to hurt someone',
      'going to kill him',
      'going to kill her',
      'going to kill them',
      'going to kill someone',
      'immediate danger',
    ];

    return highRiskPhrases.any(text.contains) ||
        RegExp(r'\b(gun|knife|weapon|weapons)\b').hasMatch(text);
  }

  bool _hasMediumRiskMeaning(String text) {
    if (text.isEmpty) {
      return false;
    }

    const mediumRiskPhrases = <String>[
      'keeps hitting me',
      'keeps happening',
      'fed up with my child',
      'boyfriend scares me',
      'girlfriend scares me',
      'partner scares me',
      'scares me sometimes',
      'crying every night',
      'about to snap',
      'feel like i’m about to snap',
      "feel like i'm about to snap",
      'feel like im about to snap',
      'cannot handle this',
      "can't handle this",
      'cant handle this',
      'i feel unsafe',
      'i feel afraid',
      'i am afraid',
      'i am scared',
      'unsafe',
      'abuse',
      'abusive',
      'violent',
      'violence',
    ];

    return mediumRiskPhrases.any(text.contains);
  }

  bool _hasEscalatedMeaning(String current, String combined) {
    final recentWasConcerning = _hasMediumRiskMeaning(combined);
    if (!recentWasConcerning) {
      return false;
    }

    const escalationSignals = <String>[
      'door',
      'leave',
      'weapon',
      'gun',
      'knife',
      'hit',
      'hurt',
      'bleeding',
      'trapped',
      'threat',
      'threatened',
      'afraid',
      'scared of what',
      'not safe',
      'unsafe',
    ];

    return escalationSignals.any(current.contains);
  }

  bool _hasUnsafeRequestMeaning(String text) {
    if (text.isEmpty) {
      return false;
    }

    const directUnsafePhrases = <String>[
      'help me hurt',
      'help me kill',
      'how do i hurt',
      'how do i kill',
      'how to hurt',
      'how to kill',
      'how to self harm',
      'how to overdose',
      'how to hide abuse',
      'hide the injury',
      'hide injuries',
      'avoid emergency care',
      'avoid calling 911',
      'get away with',
      'threaten someone',
      'punish them',
      'abuse them',
      'manipulate them',
      'commit a crime',
    ];
    if (directUnsafePhrases.any(text.contains)) {
      return true;
    }

    return RegExp(
      r'\b(help|teach|tell|show|plan|instructions)\b.*\b(hurt|kill|poison|overdose|threaten|abuse|hide)\b.*\b(myself|me|someone|him|her|them|injury|injuries|evidence|proof)\b',
    ).hasMatch(text);
  }

  static const String _emergencyModeReply =
      'I’m really sorry you’re in this. Please contact emergency services or a crisis line now. If you can, call or text someone you trust and tell them you need help right away. Do not stay alone with this.';

  static const String _unsafeRequestReply =
      'I can’t help with that. But I can help you take the next safer step right now.';

  String _friendlyError(Object error) {
    final raw = error.toString().trim();
    final message = raw.startsWith('Exception: ')
        ? raw.replaceFirst('Exception: ', '').trim()
        : raw;

    if (message.isEmpty) {
      return 'I could not complete that reply right now. Please try again.';
    }

    if (message.contains('not configured')) {
      return 'Talk to Resora is almost ready. API key is missing.';
    }
    if (message.toLowerCase().contains('timeout')) {
      return 'I could not reach the assistant in time. Try again in a moment.';
    }
    if (message.toLowerCase().contains('openai')) {
      return message;
    }

    // Keep direct message so setup issues (401/429/model access) are visible.
    return message;
  }

  @override
  void onClose() {
    dismissKeyboard();
    inputController.removeListener(_handleDraftChanged);
    inputFocusNode.removeListener(_handleInputFocusChanged);
    _sendCooldownTimer?.cancel();
    _sessionInactivityTimer?.cancel();
    _dailyLimitResetTimer?.cancel();
    _premiumWorker?.dispose();
    unawaited(_closeSessionAndUpdateMemory(reason: 'session_end'));
    inputFocusNode.dispose();
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
