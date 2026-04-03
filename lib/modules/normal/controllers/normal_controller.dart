import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class NormalController extends GetxController {
  final selectedCategory = 'All'.obs;
  final currentPage = 0.obs;

  List<String> get categories => const [
        'All',
        'Evening Stress',
        'Overwhelm',
        'Regulation',
      ];

  List<QaItem> get topics {
    if (selectedCategory.value == 'All') {
      return MockContent.normalTopics;
    }

    return MockContent.normalTopics
        .where((topic) => topic.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
    currentPage.value = 0;
  }

  void setCurrentPage(int value) {
    currentPage.value = value;
  }

  void openRelatedReset() {
    Get.toNamed(AppRoutes.resets);
  }

  void openJournal() {
    Get.toNamed(AppRoutes.journalEditor);
  }
}
