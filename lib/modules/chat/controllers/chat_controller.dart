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
  Future<void>? _bootstrapFuture;
  Timer? _sendCooldownTimer;
  Timer? _sessionInactivityTimer;
  Timer? _dailyLimitResetTimer;
  Worker? _premiumWorker;
  bool _isClosingSession = false;
  bool _isUpdatingMemory = false;
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
    _bootstrapFuture = _bootstrapSessionHistory();
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
          ? _emergencyModeReplyFor(text)
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
    await _bootstrapFuture;
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
        unawaited(_updateMemoryFromCurrentSession());
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
      unawaited(_updateMemoryFromCurrentSession());
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
      final previousSessionId =
          await _chatSessionService.loadActiveSessionId(uid);
      if (isClosed) {
        return;
      }
      messages.clear();

      if (previousSessionId == null) {
        return;
      }

      _activeSessionId = previousSessionId;
      await _closeSessionAndUpdateMemory(reason: 'app_reopened');
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
      await _updateMemoryFromCurrentSession();
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

  Future<void> _updateMemoryFromCurrentSession() async {
    if (_isUpdatingMemory) {
      return;
    }

    final uid = _session.firebaseUser?.uid;
    final sessionId = _activeSessionId;
    if (uid == null || sessionId == null || sessionId.trim().isEmpty) {
      return;
    }

    _isUpdatingMemory = true;
    try {
      final transcript = await _chatSessionService.loadSessionTranscript(
        uid: uid,
        sessionId: sessionId,
      );
      if (transcript.isEmpty) {
        return;
      }
      final existingMemory = await _chatSessionService.loadMemoryProfile(uid);
      final updates = await _aiService.updateMemoryFromTranscript(
        existingMemory: existingMemory,
        transcript: transcript,
      );
      await _chatSessionService.updateMemoryProfile(uid: uid, updates: updates);
    } catch (_) {
      // Memory updates are best effort and should never block chat.
    } finally {
      _isUpdatingMemory = false;
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
    final recent = _normalizeSafetyText(recentUserText);
    final combined = _normalizeSafetyText('$recentUserText $text');

    final unsafeRequest = _hasUnsafeRequestMeaning(current);
    final currentHighRisk =
        _hasHighRiskMeaning(current) && !_isSafetyReassurance(current);
    final highRisk = currentHighRisk ||
        _hasEscalatedMeaning(current, combined) ||
        _hasHighRiskFollowUpMeaning(current: current, recent: recent);
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
      'cut today',
      'cut again tonight',
      'might cut again',
      'wound that needs care',
      'overdose',
      'i overdosed',
      'took too many pills',
      'took too much',
      'took a bunch of medication',
      'mixed pills and alcohol',
      'mixed alcohol and pills',
      'drank poison',
      'poisoned myself',
      'child got into pills',
      'child drank something poisonous',
      'child drank cleaning spray',
      'cannot stay safe',
      "can't stay safe",
      'cant stay safe',
      'have a plan',
      'about to do it',
      'cant breathe',
      "can't breathe",
      'cannot breathe',
      'trouble breathing',
      'not breathing',
      'turning blue',
      'gasping for air',
      'choking',
      'is choking',
      'throat is swelling',
      'tongue is swelling',
      'face is swelling',
      'severe allergic reaction',
      'bleeding badly',
      'wont stop bleeding',
      "won't stop bleeding",
      'unconscious',
      'passed out and wont wake up',
      "passed out and won't wake up",
      'seizure',
      'head injury',
      'chest pain',
      'stroke symptoms',
      'serious injury',
      'has a weapon',
      'he has a weapon',
      'she has a weapon',
      'they have a weapon',
      'has a gun',
      'has a knife',
      'won’t let me leave',
      "won't let me leave",
      'wont let me leave',
      'blocks the door',
      'blocked the door',
      'trapped',
      'being trapped',
      'being attacked',
      'going to kill me',
      'threatening me right now',
      'child is not safe',
      'baby isnt breathing',
      "baby isn't breathing",
      'hurting my child right now',
      'elder is in immediate danger',
      'disabled person is in immediate danger',
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
    if (_isSafetyReassurance(current)) {
      return false;
    }

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

  bool _hasHighRiskFollowUpMeaning({
    required String current,
    required String recent,
  }) {
    if (_isSafetyReassurance(current) ||
        !_hasHighRiskMeaning(recent) ||
        current.isEmpty) {
      return false;
    }

    const followUpSignals = <String>[
      'i have a plan',
      'have a plan',
      'about to do it',
      'tonight',
      'right now',
      'now',
      'pills',
      'medication',
      'knife',
      'gun',
      'weapon',
      'cant stay safe',
      "can't stay safe",
      'cannot stay safe',
      'i took them',
      'took them',
      'i did it',
      'did it',
      'alone',
    ];
    return followUpSignals.any(current.contains);
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

  bool _isSafetyReassurance(String text) {
    if (text.isEmpty || text.length > 120) {
      return false;
    }

    final statesSafe = RegExp(
      r"\b(i am|i'm|im|we are|we're|were|they are|they're|theyre)?\s*(physically\s+)?safe\b",
    ).hasMatch(text);
    final deniesImmediateDanger = text.contains('no immediate danger') ||
        text.contains('not in immediate danger') ||
        text.contains('i can stay safe');
    final deniesLifeEnding = text.contains('i dont want to die') ||
        text.contains("i don't want to die") ||
        text.contains('not suicidal');
    final deniesSelfInjury = text.contains('not going to hurt myself') ||
        text.contains("i won't hurt myself") ||
        text.contains('i wont hurt myself') ||
        text.contains('not going to harm myself') ||
        text.contains("i won't harm myself") ||
        text.contains('i wont harm myself');
    final hasSafeSignal = statesSafe ||
        deniesImmediateDanger ||
        deniesLifeEnding ||
        deniesSelfInjury;
    if (!hasSafeSignal) {
      return false;
    }

    const urgentSignals = <String>[
      'but i want to die',
      'but i might',
      'but i may',
      'but i took',
      'but someone',
      'gun',
      'knife',
      'weapon',
      'poison',
      'overdose',
      'pills',
      'cannot breathe',
      "can't breathe",
      'cant breathe',
      'choking',
      'bleeding',
      'swelling',
      'trapped',
      'wont let me leave',
      "won't let me leave",
      'kill me',
    ];
    return !urgentSignals.any(text.contains);
  }

  String _emergencyModeReplyFor(String text) {
    final normalized = _normalizeSafetyText(text);

    if (_mentionsChildPoisoning(normalized)) {
      return 'Call emergency services or Poison Control now. Do not wait to see if it passes. Keep the container nearby so responders can see what was swallowed. Is the child breathing and physically safe right now?';
    }
    if (_mentionsPoisoningOrOverdose(normalized)) {
      return 'Call emergency services or Poison Control now. Do not wait to see if it passes. Move away from anything else you could take and stay where help can reach you. Are you physically safe right now?';
    }
    if (_mentionsSubstanceEmergency(normalized)) {
      return 'This needs immediate support. Contact 988 now for substance use crisis support. If you used too much, mixed substances, cannot stay awake, cannot breathe, feel out of control, or might drive, call emergency services now. Move somewhere safer if you can. Are you physically safe right now?';
    }
    if (_mentionsChokingOrBreathing(normalized)) {
      return 'Call emergency services now. If the person cannot breathe, cough, cry, or make sound, get emergency help immediately and start first aid if you know how. Is the person breathing right now?';
    }
    if (_mentionsAllergicReaction(normalized)) {
      return 'Call emergency services now. Throat, tongue, or face swelling can become dangerous quickly. Sit upright and do not wait to see if it passes. Are you breathing okay right now?';
    }
    if (_mentionsWeaponTrapOrViolence(normalized)) {
      return 'Call emergency services now if you can do that safely. If calling could make things worse, move toward a safer or more public place if possible. Are you physically safe right now?';
    }
    if (_mentionsSeriousInjury(normalized)) {
      return 'Call emergency services now. Keep pressure on heavy bleeding if you can do that safely and avoid moving someone with a serious head, neck, or spine injury unless staying there is more dangerous. Is the person awake and breathing?';
    }
    if (_mentionsDependentDanger(normalized)) {
      return 'Call emergency services or Poison Control now, depending on what happened. Keep the child, elder, or dependent away from the danger if you can do that safely. Are they breathing and physically safe right now?';
    }
    if (_mentionsCuttingOrCannotStaySafe(normalized)) {
      return 'This needs immediate support. Contact 988, emergency services or their crisis care team now. Move sharp objects, medications and anything dangerous away if you can do that safely. Stay nearby without arguing or escalating. Are they physically safe right now?';
    }

    return 'This needs immediate support. Contact 988 now. If there is immediate danger, call emergency services now. Move away from anything dangerous and go somewhere more visible or populated if you can. Are you physically safe right now?';
  }

  bool _mentionsChildPoisoning(String text) {
    return text.contains('child got into pills') ||
        text.contains('child drank something poisonous') ||
        text.contains('child drank cleaning spray') ||
        text.contains('baby drank') ||
        text.contains('kid drank poison');
  }

  bool _mentionsPoisoningOrOverdose(String text) {
    const phrases = <String>[
      'took too many pills',
      'took too much',
      'overdose',
      'overdosed',
      'drank poison',
      'mixed pills and alcohol',
      'mixed alcohol and pills',
      'took a bunch of medication',
      'poisoned myself',
      'feel sick after taking',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsSubstanceEmergency(String text) {
    const phrases = <String>[
      'used too much',
      'drank too much and cant stay awake',
      "drank too much and can't stay awake",
      'used and cant breathe',
      "used and can't breathe",
      'mixed drugs',
      'might overdose',
      'cant stop using tonight',
      "can't stop using tonight",
      'high and driving',
      'drunk and driving',
      'someone passed out after using',
      'wont wake up after drinking',
      "won't wake up after drinking",
      'wont wake up after using',
      "won't wake up after using",
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsChokingOrBreathing(String text) {
    const phrases = <String>[
      'cant breathe',
      "can't breathe",
      'cannot breathe',
      'not breathing',
      'choking',
      'turning blue',
      'gasping for air',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsAllergicReaction(String text) {
    const phrases = <String>[
      'throat is swelling',
      'tongue is swelling',
      'face is swelling',
      'severe allergic reaction',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsWeaponTrapOrViolence(String text) {
    const phrases = <String>[
      'has a gun',
      'has a knife',
      'has a weapon',
      'wont let me leave',
      "won't let me leave",
      'blocks the door',
      'blocked the door',
      'trapped',
      'being attacked',
      'going to kill me',
      'threatening me right now',
    ];
    return phrases.any(text.contains) ||
        RegExp(r'\b(gun|knife|weapon|weapons)\b').hasMatch(text);
  }

  bool _mentionsSeriousInjury(String text) {
    const phrases = <String>[
      'bleeding badly',
      'wont stop bleeding',
      "won't stop bleeding",
      'unconscious',
      'passed out and wont wake up',
      "passed out and won't wake up",
      'seizure',
      'head injury',
      'chest pain',
      'stroke symptoms',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsDependentDanger(String text) {
    const phrases = <String>[
      'child is not safe',
      'cant keep my child safe',
      "can't keep my child safe",
      'cannot keep my child safe',
      'baby isnt breathing',
      "baby isn't breathing",
      'hurting my child right now',
      'elder is in immediate danger',
      'disabled person is in immediate danger',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsCuttingOrCannotStaySafe(String text) {
    const phrases = <String>[
      'cut today',
      'cut again tonight',
      'might cut again',
      'cut myself',
      'cannot stay safe',
      "can't stay safe",
      'cant stay safe',
      'cannot keep myself safe',
      "can't keep myself safe",
      'cant keep myself safe',
      'cannot keep them safe',
      "can't keep them safe",
      'cant keep them safe',
      'wound that needs care',
    ];
    return phrases.any(text.contains);
  }

  static const String _unsafeRequestReply =
      'I can’t help with that part. I can help you take a safer next step right now.';

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
