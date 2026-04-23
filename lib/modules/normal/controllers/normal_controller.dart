import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/content_items_service.dart';
import '../../../core/services/user_generated_content_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class NormalController extends GetxController {
  NormalController({
    ContentItemsService? contentItemsService,
    UserGeneratedContentService? userGeneratedContentService,
  })  : _contentItemsService = contentItemsService ?? ContentItemsService(),
        _userGeneratedContentService =
            userGeneratedContentService ?? UserGeneratedContentService();

  final ContentItemsService _contentItemsService;
  final UserGeneratedContentService _userGeneratedContentService;
  final _session = Get.find<AppSessionController>();

  final selectedCategory = 'all'.obs;
  final sortMode = 'felt'.obs;
  final questionDraft = ''.obs;
  final isSubmittingQuestion = false.obs;

  final askController = TextEditingController();

  final localVoices = <String, List<String>>{}.obs;
  final _savedVoices = <String, List<String>>{}.obs;
  final _remoteTopics = <NormalTopicItem>[].obs;
  final _submittedTopics = <NormalTopicItem>[].obs;
  StreamSubscription<List<NormalTopicItem>>? _remoteTopicsSubscription;
  StreamSubscription<List<NormalTopicItem>>? _submittedTopicsSubscription;
  StreamSubscription<Map<String, List<String>>>? _voicesSubscription;

  List<NormalTopicItem> get _baseTopics => _remoteTopics;

  List<NormalTopicItem> get _allTopics {
    final publishedKeys =
        _baseTopics.map((item) => _topicKey(item.question)).toSet();
    final pendingUserTopics = _submittedTopics
        .where((item) => !publishedKeys.contains(_topicKey(item.question)))
        .toList();

    return [
      ...pendingUserTopics,
      ..._baseTopics,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    _startLiveSync();
  }

  void _startLiveSync() {
    _remoteTopicsSubscription?.cancel();
    _remoteTopicsSubscription = _contentItemsService.watchNormalTopics().listen(
      (topics) {
        _remoteTopics.assignAll(topics);
        _reconcileSubmittedTopics();
        _ensureCategoryStillValid();
      },
      onError: (_) {
        _remoteTopics.clear();
        _reconcileSubmittedTopics();
      },
    );

    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      _submittedTopics.clear();
      _savedVoices.clear();
      return;
    }

    _submittedTopicsSubscription?.cancel();
    _submittedTopicsSubscription =
        _userGeneratedContentService.watchNormalQuestions(uid).listen(
      (questions) {
        _submittedTopics.assignAll(questions);
        _reconcileSubmittedTopics();
        _ensureCategoryStillValid();
      },
      onError: (_) {
        _submittedTopics.clear();
      },
    );

    _voicesSubscription?.cancel();
    _voicesSubscription =
        _userGeneratedContentService.watchNormalVoicesByTopic(uid).listen(
      (voices) {
        _savedVoices.assignAll(voices);
      },
      onError: (_) {
        _savedVoices.clear();
      },
    );
  }

  void _reconcileSubmittedTopics() {
    final publishedKeys =
        _baseTopics.map((item) => _topicKey(item.question)).toSet();
    _submittedTopics.assignAll(
      _submittedTopics
          .where((item) => !publishedKeys.contains(_topicKey(item.question)))
          .toList(),
    );
  }

  void _ensureCategoryStillValid() {
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
    final key = _topicKey(topic.question);
    return [
      ...topic.voices,
      ...(_savedVoices[key] ?? const <String>[]),
      ...(localVoices[key] ?? const <String>[]),
    ];
  }

  Future<bool> addVoiceFor({
    required NormalTopicItem topic,
    required String voice,
  }) async {
    final text = voice.trim();
    if (text.isEmpty) {
      return false;
    }

    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      showAppSnackbar(
        'Sign in required',
        'Please sign in to save your voice.',
      );
      return false;
    }

    final key = _topicKey(topic.question);
    final existing = List<String>.from(localVoices[key] ?? const []);
    existing.add(text);
    localVoices[key] = existing;

    try {
      await _userGeneratedContentService.submitNormalVoice(
        uid: uid,
        topicQuestion: topic.question,
        voice: text,
      );

      final persisted = List<String>.from(_savedVoices[key] ?? const []);
      persisted.add(text);
      _savedVoices[key] = persisted;
      localVoices.remove(key);
      return true;
    } catch (_) {
      showAppSnackbar(
        'Could not submit voice',
        'Your voice could not be saved right now. Please try again.',
      );
      return false;
    }
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

  Future<void> submitQuestion() async {
    final text = questionDraft.value.trim();
    if (text.isEmpty) {
      return;
    }
    if (isSubmittingQuestion.value) {
      return;
    }

    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      showAppSnackbar(
        'Sign in required',
        'Please sign in to submit your question.',
      );
      return;
    }

    final category =
        selectedCategory.value == 'all' ? 'community' : selectedCategory.value;

    isSubmittingQuestion.value = true;
    try {
      await _userGeneratedContentService.submitNormalQuestion(
        uid: uid,
        question: text,
        category: category,
        submittedByName: _session.displayName,
      );

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
    } catch (_) {
      showAppSnackbar(
        'Could not submit question',
        'Your question could not be saved right now. Please try again.',
      );
    } finally {
      isSubmittingQuestion.value = false;
    }
  }

  static String _topicKey(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void onClose() {
    _remoteTopicsSubscription?.cancel();
    _submittedTopicsSubscription?.cancel();
    _voicesSubscription?.cancel();
    askController.dispose();
    super.onClose();
  }
}
