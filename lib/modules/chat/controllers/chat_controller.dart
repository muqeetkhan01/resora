import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/resora_ai_service.dart';
import '../../../data/models/app_models.dart';

class ChatController extends GetxController {
  ChatController({ResoraAiService? aiService})
      : _aiService = aiService ?? ResoraAiService();

  final ResoraAiService _aiService;
  final _session = Get.find<AppSessionController>();

  final inputController = TextEditingController();
  final scrollController = ScrollController();
  final messages = <ChatMessageModel>[].obs;
  final isTyping = false.obs;
  final draftText = ''.obs;

  int _pendingReplies = 0;

  bool get canSend => draftText.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    inputController.addListener(_handleDraftChanged);
  }

  Future<void> sendMessage([String? preset]) async {
    final text = (preset ?? inputController.text).trim();
    if (text.isEmpty) return;

    messages.add(ChatMessageModel(text: text, isUser: true, time: 'Now'));
    inputController.clear();
    _pendingReplies += 1;
    isTyping.value = true;
    _scrollToBottom();

    try {
      final reply = await _aiService.generateReply(
        messages: messages.toList(),
        userName: _session.displayName,
      );
      messages.add(
        ChatMessageModel(
          text: reply,
          isUser: false,
          time: 'Now',
        ),
      );
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
    inputController.removeListener(_handleDraftChanged);
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
