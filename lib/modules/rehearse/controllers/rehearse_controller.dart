import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

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
      AppRoutes.audioPlayer,
      arguments: {
        'track': AudioTrack(
          title: scenario.title,
          category: scenario.category,
          description: scenario.reframe,
          duration: '7 min',
        ),
        'imagePath': AppAssets.curtainLight,
        'minimal': true,
      },
    );
  }

  void saveToJournal(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.journalEditor);
  }

  void practiceAgain(RehearsalScenario scenario) {
    Get.toNamed(AppRoutes.chat);
  }
}
