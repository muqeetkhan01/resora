import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class ChatController extends GetxController {
  final inputController = TextEditingController();
  final messages = <ChatMessageModel>[...MockContent.chatMessages].obs;
  final suggestions = MockContent.suggestedPrompts;
  final isTyping = false.obs;
  final freeMessagesRemaining = 3.obs;

  void sendMessage([String? preset]) {
    final text = (preset ?? inputController.text).trim();
    if (text.isEmpty) return;

    messages.add(ChatMessageModel(text: text, isUser: true, time: 'Now'));
    inputController.clear();
    isTyping.value = true;

    if (freeMessagesRemaining.value > 0) {
      freeMessagesRemaining.value -= 1;
    }

    Future<void>.delayed(const Duration(milliseconds: 700), () {
      isTyping.value = false;
      messages.add(
        ChatMessageModel(
          text: _buildMockReply(text),
          isUser: false,
          time: 'Now',
        ),
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
    inputController.dispose();
    super.onClose();
  }
}
