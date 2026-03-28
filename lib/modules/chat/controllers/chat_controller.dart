import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class ChatController extends GetxController {
  final inputController = TextEditingController();
  final messages = <ChatMessageModel>[...MockContent.chatMessages].obs;
  final suggestions = MockContent.suggestedPrompts;

  void sendMessage([String? preset]) {
    final text = (preset ?? inputController.text).trim();
    if (text.isEmpty) return;

    messages.add(ChatMessageModel(text: text, isUser: true, time: 'Now'));
    inputController.clear();

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      messages.add(
        const ChatMessageModel(
          text:
              'This is a mock assistant response for the UI. Later we can connect this screen to OpenAI or your preferred backend.',
          isUser: false,
          time: 'Now',
        ),
      );
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }
}
