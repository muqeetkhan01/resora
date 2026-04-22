import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class RehearseController extends GetxController {
  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;

  List<String> get categories => const [
        'all',
        'connect',
        'release',
        'clarity',
        'ground',
      ];

  List<RehearsalScenario> get scenarios => MockContent.rehearsalScenarios;

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
            assetPath: _assetForScenario(scenario),
          ),
          'imagePath': AppAssets.curtainLight,
          'minimal': true,
          'ritualFeature': RitualWrapFeature.visualization,
        },
      ).toMap(),
    );
  }

  void saveToJournal(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.journalEditor);
  }

  void practiceAgain(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.chat);
  }

  String _assetForScenario(RehearsalScenario scenario) {
    switch (scenario.title) {
      case 'Talking to my partner after a hard night':
        return AppAssets.rehearsePartnerAfterHardNight;
      case 'Setting a limit with someone I care about':
        return AppAssets.rehearseSettingLimit;
      case 'Asking for what I actually need':
        return AppAssets.rehearseAskForNeed;
      case 'Repairing after I lost my temper':
        return AppAssets.rehearseRepairAfterTemper;
      case 'Handling a hard conversation at work':
        return AppAssets.rehearseHardConversationWork;
      default:
        return AppAssets.rehearseAskForNeed;
    }
  }
}
