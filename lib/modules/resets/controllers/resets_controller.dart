import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ResetsController extends GetxController {
  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;

  List<String> get categories => const [
        'all',
        'ground',
        'release',
        'clarity',
        'restore',
      ];

  List<ResetOption> get options => MockContent.resetOptions;

  List<ResetOption> get filteredOptions {
    if (selectedCategory.value == 'all') {
      return options;
    }

    return options
        .where(
          (option) => option.category.toLowerCase() == selectedCategory.value,
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
    Get.toNamed(
      AppRoutes.audioPlayer,
      arguments: {
        'track': AudioTrack(
          title: option.title,
          category: option.category,
          description: option.subtitle,
          duration: option.duration,
        ),
        'imagePath': AppAssets.archway,
        'minimal': true,
      },
    );
  }
}
