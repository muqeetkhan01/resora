import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class RehearseController extends GetxController {
  RehearseController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final _scenarios = <RehearsalScenario>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final scenarios = await _contentItemsService.loadRehearsalScenarios();
      _scenarios.assignAll(scenarios);
    } catch (_) {
      _scenarios.clear();
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
    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.visualization,
        nextRoute: AppRoutes.audioPlayer,
        nextArguments: {
          'track': AudioTrack(
            title: scenario.title,
            category: scenario.category,
            description: scenario.reframe,
            duration: '7 min',
            assetPath: scenario.audioPath.isEmpty
                ? AppAssets.rehearseAskForNeed
                : scenario.audioPath,
          ),
          'imagePath': AppAssets.curtainLight,
          'minimal': true,
          'ritualFeature': RitualWrapFeature.visualization,
        },
      ).toMap(),
    );
  }

  Future<void> saveToJournal(RehearsalScenario scenario) async {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final unlocked = await profile.ensureJournalUnlocked();
    if (!unlocked) {
      return;
    }

    Get.toNamed(AppRoutes.journalEditor);
  }

  void practiceAgain(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.chat);
  }
}
