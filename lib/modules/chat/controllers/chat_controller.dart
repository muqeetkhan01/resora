import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/app_models.dart';

class ChatController extends GetxController {
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

  void sendMessage([String? preset]) {
    final text = (preset ?? inputController.text).trim();
    if (text.isEmpty) return;

    messages.add(ChatMessageModel(text: text, isUser: true, time: 'Now'));
    inputController.clear();
    _pendingReplies += 1;
    isTyping.value = true;
    _scrollToBottom();

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      messages.add(
        ChatMessageModel(
          text: _buildMockReply(text),
          isUser: false,
          time: 'Now',
        ),
      );
      _pendingReplies = (_pendingReplies - 1).clamp(0, 999);
      isTyping.value = _pendingReplies > 0;
      _scrollToBottom();
    });
  }

  void _handleDraftChanged() {
    draftText.value = inputController.text;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _buildMockReply(String text) {
    final lowered = text.toLowerCase();

    if (lowered.contains('snap') || lowered.contains('overwhelmed')) {
      return 'Let’s slow this down. That is a normal response to an overloaded moment. Start with one two-minute reset, then come back if you want help with what to say next.';
    }
    if (lowered.contains('conversation') || lowered.contains('script')) {
      return 'It makes sense that you want a cleaner way into this conversation. Keep it short first. Say the point, then the ask. If you want, I can help you rehearse the exact wording.';
    }
    if (lowered.contains('journal')) {
      return 'You do not need a long entry. Write three honest lines, then stop. If it helps, open Journal with the prompt: what helped more than I expected?';
    }

    return 'That is a normal response to a full moment. Start smaller than your mind wants to. Take one breath, lower the pace, and choose the next helpful step rather than the whole solution.';
  }

  @override
  void onClose() {
    inputController.removeListener(_handleDraftChanged);
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
