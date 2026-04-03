import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ResetsController extends GetxController {
  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;

  List<String> get categories => const [
        'all',
        'breath',
        'grounding',
        'pause',
      ];

  List<ResetOption> get options => MockContent.resetOptions;

  List<ResetOption> get filteredOptions {
    if (selectedCategory.value == 'all') {
      return options;
    }

    return options
        .where(
          (option) =>
              option.title.toLowerCase().contains(selectedCategory.value),
        )
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    currentPage.value = 0;
  }

  void setCurrentPage(int page) {
    currentPage.value = page;
  }

  void openReset(ResetOption option) {
    Get.toNamed(AppRoutes.resetSession, arguments: option);
  }
}
