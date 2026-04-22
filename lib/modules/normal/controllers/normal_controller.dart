import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class NormalController extends GetxController {
  NormalController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final sortMode = 'felt'.obs;
  final questionDraft = ''.obs;

  final askController = TextEditingController();

  final localVoices = <String, List<String>>{}.obs;
  final _remoteTopics = <NormalTopicItem>[].obs;
  final _submittedTopics = <NormalTopicItem>[].obs;

  List<NormalTopicItem> get _baseTopics => _remoteTopics;

  List<NormalTopicItem> get _allTopics => [
        ..._submittedTopics,
        ..._baseTopics,
      ];

  @override
  void onInit() {
    super.onInit();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await _contentItemsService.loadNormalTopics();
      _remoteTopics.assignAll(topics);
    } catch (_) {
      _remoteTopics.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'all';
    }
  }

  List<String> get categories {
    final values = <String>['all'];

    for (final topic in _allTopics) {
      final tab = topic.tab.trim().toLowerCase();
      if (tab.isEmpty || values.contains(tab)) {
        continue;
      }
      values.add(tab);
    }

    return values;
  }

  List<NormalTopicItem> get topics {
    final selected = selectedCategory.value;
    final filtered = selected == 'all'
        ? List<NormalTopicItem>.from(_allTopics)
        : _allTopics
            .where((topic) => topic.tab.toLowerCase() == selected)
            .toList();

    if (sortMode.value == 'latest') {
      return filtered;
    }

    filtered.sort((a, b) => b.metoo.compareTo(a.metoo));
    return filtered;
  }

  String categoryLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'all':
        return 'all';
      case 'overwhelm':
        return 'release';
      case 'regulation':
        return 'ground';
      case 'identity':
        return 'clarity';
      case 'sleep':
        return 'restore';
      case 'connection':
        return 'connect';
      default:
        return value;
    }
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
  }

  void setSortMode(String value) {
    sortMode.value = value;
  }

  List<String> voicesFor(NormalTopicItem topic) {
    return [
      ...topic.voices,
      ...(localVoices[topic.question] ?? const <String>[]),
    ];
  }

  void addVoiceFor({
    required NormalTopicItem topic,
    required String voice,
  }) {
    final text = voice.trim();
    if (text.isEmpty) {
      return;
    }

    final existing = List<String>.from(localVoices[topic.question] ?? const []);
    existing.add(text);
    localVoices[topic.question] = existing;
  }

  void openAskQuestion() {
    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.normal,
        nextRoute: AppRoutes.normalAsk,
      ).toMap(),
    );
  }

  void updateQuestionDraft(String value) {
    questionDraft.value = value;
  }

  bool get canSubmitQuestion => questionDraft.value.trim().isNotEmpty;

  void submitQuestion() {
    final text = questionDraft.value.trim();
    if (text.isEmpty) {
      return;
    }

    final category =
        selectedCategory.value == 'all' ? 'community' : selectedCategory.value;

    _submittedTopics.insert(
      0,
      NormalTopicItem(
        tab: category,
        question: text,
        expertAnswer:
            'Thank you for sharing this. Our team will respond with a grounded answer soon.',
        metoo: 1,
        voices: const [],
        expertByline: 'Resora',
      ),
    );

    askController.clear();
    questionDraft.value = '';

    Get.offNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.exit(
        feature: RitualWrapFeature.normal,
      ).toMap(),
    );
  }

  @override
  void onClose() {
    askController.dispose();
    super.onClose();
  }
}
