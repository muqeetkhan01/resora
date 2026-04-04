import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class NormalController extends GetxController {
  final selectedCategory = 'all'.obs;
  final voiceDraft = ''.obs;
  final currentCardIndex = 0.obs;
  final showingVoiceEditor = false.obs;
  final showingVoiceConfirmation = false.obs;
  final voiceInputController = TextEditingController();
  final localVoices = <String, List<String>>{}.obs;

  List<String> get categories => const [
        'all',
        'evening stress',
        'overwhelm',
        'regulation',
        'sleep',
      ];

  List<NormalTopicItem> get topics {
    if (selectedCategory.value == 'all') {
      return MockContent.normalTopics;
    }

    return MockContent.normalTopics
        .where((topic) => topic.tab == selectedCategory.value)
        .toList();
  }

  NormalTopicItem get currentTopic => topics[currentCardIndex.value];

  bool get hasPreviousTopic => currentCardIndex.value > 0;

  bool get hasNextTopic => currentCardIndex.value < topics.length - 1;

  bool get canSubmitVoice => voiceDraft.value.trim().isNotEmpty;

  List<String> voicesFor(NormalTopicItem topic) => [
        ...topic.voices,
        ...(localVoices[topic.question] ?? const <String>[]),
      ];

  void selectCategory(String value) {
    selectedCategory.value = value;
    currentCardIndex.value = 0;
    _resetVoiceState();
  }

  void previousTopic() {
    if (!hasPreviousTopic) return;
    currentCardIndex.value -= 1;
    _resetVoiceState();
  }

  void nextTopic() {
    if (!hasNextTopic) return;
    currentCardIndex.value += 1;
    _resetVoiceState();
  }

  void addYourVoice() {
    showingVoiceEditor.value = true;
    showingVoiceConfirmation.value = false;
    voiceDraft.value = '';
    voiceInputController.clear();
  }

  void updateVoiceDraft(String value) {
    voiceDraft.value = value;
  }

  void cancelVoiceEntry() {
    _resetVoiceState();
  }

  void submitVoice() {
    final text = voiceDraft.value.trim();
    if (text.isEmpty) return;

    final existing =
        List<String>.from(localVoices[currentTopic.question] ?? const []);
    existing.add(text);
    localVoices[currentTopic.question] = existing;

    showingVoiceEditor.value = false;
    showingVoiceConfirmation.value = true;
    voiceDraft.value = '';
    voiceInputController.clear();
  }

  void dismissVoiceConfirmation() {
    _resetVoiceState();
  }

  void openRelatedReset() {
    Get.toNamed(AppRoutes.resets);
  }

  void askDifferentQuestion() {
    Get.toNamed(AppRoutes.chat);
  }

  void _resetVoiceState() {
    showingVoiceEditor.value = false;
    showingVoiceConfirmation.value = false;
    voiceDraft.value = '';
    voiceInputController.clear();
  }

  @override
  void onClose() {
    voiceInputController.dispose();
    super.onClose();
  }
}
