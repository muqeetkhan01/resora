import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class NormalController extends GetxController {
  NormalController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final voiceDraft = ''.obs;
  final currentCardIndex = 0.obs;
  final showingVoiceEditor = false.obs;
  final showingVoiceConfirmation = false.obs;
  final voiceInputController = TextEditingController();
  final localVoices = <String, List<String>>{}.obs;
  final _remoteTopics = <NormalTopicItem>[].obs;

  List<NormalTopicItem> get _sourceTopics {
    if (_remoteTopics.isNotEmpty) {
      return _remoteTopics;
    }
    return MockContent.normalTopics;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await _contentItemsService.loadNormalTopics();
      if (topics.isNotEmpty) {
        _remoteTopics.assignAll(topics);
      }
      _normalizeSelection();
    } catch (_) {
      _remoteTopics.clear();
      _normalizeSelection();
    }
  }

  List<String> get categories {
    final values = <String>['all'];
    for (final topic in _sourceTopics) {
      final tab = topic.tab.trim();
      if (tab.isEmpty || values.contains(tab)) {
        continue;
      }
      values.add(tab);
    }
    return values;
  }

  List<NormalTopicItem> get topics {
    if (selectedCategory.value == 'all') {
      return _sourceTopics;
    }

    return _sourceTopics
        .where((topic) => topic.tab == selectedCategory.value)
        .toList();
  }

  NormalTopicItem get currentTopic {
    final list = topics;
    if (list.isEmpty) {
      return MockContent.normalTopics.first;
    }
    final safeIndex = currentCardIndex.value.clamp(0, list.length - 1);
    return list[safeIndex];
  }

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

  void _normalizeSelection() {
    final tabs = categories;
    if (!tabs.contains(selectedCategory.value)) {
      selectedCategory.value = 'all';
    }

    final list = topics;
    if (list.isEmpty) {
      currentCardIndex.value = 0;
      return;
    }

    if (currentCardIndex.value > list.length - 1) {
      currentCardIndex.value = list.length - 1;
    }
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
