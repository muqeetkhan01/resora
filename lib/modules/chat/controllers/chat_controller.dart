import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/chat_session_service.dart';
import '../../../core/services/resora_ai_service.dart';
import '../../../data/models/app_models.dart';

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

  int _pendingReplies = 0;
  String? _activeSessionId;
  Timer? _sendCooldownTimer;
  Timer? _sessionInactivityTimer;
  bool _isClosingSession = false;

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
    _bootstrapSessionHistory();
  }

  Future<void> sendMessage([String? preset]) async {
    final text = (preset ?? inputController.text).trim();
    dismissKeyboard();
    if (text.isEmpty || isSendCooldownActive.value || isTyping.value) return;
    if (text.characters.length > maxCharacters) return;

    _startSendCooldown();

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
        );
        await _chatSessionService.touchSession(uid, sessionId);
        _restartSessionInactivityTimer();
        contextWindow = await _chatSessionService.loadRecentMessages(
          uid: uid,
          sessionId: sessionId,
          limit: 20,
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
      _scrollToBottom();
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
        limit: 20,
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
    unawaited(_closeSessionAndUpdateMemory(reason: 'session_end'));
    inputFocusNode.dispose();
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
