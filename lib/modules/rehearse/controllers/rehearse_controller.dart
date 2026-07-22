import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/services/content_items_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class RehearseController extends GetxController {
  RehearseController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final isLoading = true.obs;
  final _scenarios = <RehearsalScenario>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    isLoading.value = true;
    try {
      final scenarios = await _contentItemsService.loadRehearsalScenarios();
      _scenarios.assignAll(scenarios);
    } catch (_) {
      _scenarios.clear();
    } finally {
      isLoading.value = false;
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'all';
    }
  }

  List<String> get categories {
    final values = <String>['all'];
    for (final scenario in _scenarios) {
      final category = scenario.category.trim().toLowerCase();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }
    return values;
  }

  List<RehearsalScenario> get scenarios => _scenarios;
  bool get hasPremiumAccess =>
      Get.isRegistered<SubscriptionService>() &&
      Get.find<SubscriptionService>().isPremium.value;

  List<RehearsalScenario> get filteredScenarios {
    if (selectedCategory.value == 'all') {
      return scenarios;
    }

    return scenarios
        .where((scenario) =>
            scenario.category.toLowerCase() == selectedCategory.value)
        .toList();
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
    currentPage.value = 0;
  }

  void setCurrentPage(int value) {
    currentPage.value = value;
  }

  void openScenario(RehearsalScenario scenario) {
    final audioPath = scenario.audioPath.isEmpty
        ? _fallbackAudioFor(scenario)
        : scenario.audioPath;
    final imagePath = scenario.imagePath.isEmpty
        ? _fallbackImageFor(scenario)
        : scenario.imagePath;

    final playerArgs = {
      'track': AudioTrack(
        title: scenario.title,
        category: scenario.category,
        description: scenario.reframe,
        duration: '7 min',
        assetPath: audioPath,
        imagePath: imagePath,
      ),
      'imagePath': imagePath,
      'minimal': true,
      'ritualFeature': RitualWrapFeature.visualization,
      'previewOnly': scenario.isPremium && !hasPremiumAccess,
    };

    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.visualization,
        nextRoute: AppRoutes.audioPlayer,
        nextArguments: playerArgs,
      ).toMap(),
    );
  }

  void saveToJournal(RehearsalScenario scenario) {
    if (scenario.isPremium && !hasPremiumAccess) {
      Get.toNamed(AppRoutes.subscription);
      return;
    }
    Get.toNamed(AppRoutes.journalEditor);
  }

  void practiceAgain(RehearsalScenario scenario) {
    AppNavigation.openTalkTab();
  }

  String _fallbackAudioFor(RehearsalScenario scenario) {
    final title = scenario.title.toLowerCase();
    final category = scenario.category.toLowerCase();
    if (title.contains('partner') || category.contains('connect')) {
      return AppAssets.rehearsePartnerAfterHardNight;
    }
    if (title.contains('work') || category.contains('clarity')) {
      return AppAssets.rehearseHardConversationWork;
    }
    if (title.contains('limit') || category.contains('release')) {
      return AppAssets.rehearseSettingLimit;
    }
    if (title.contains('temper')) return AppAssets.rehearseRepairAfterTemper;
    return AppAssets.rehearseAskForNeed;
  }

  String _fallbackImageFor(RehearsalScenario scenario) {
    final category = scenario.category.toLowerCase();
    if (category.contains('ground')) return AppAssets.archway;
    if (category.contains('release')) return AppAssets.spaceGarden;
    if (category.contains('clarity')) return AppAssets.splashWaterfall;
    if (category.contains('restore')) return AppAssets.splashLivingRoom;
    return AppAssets.curtainLight;
  }
}
