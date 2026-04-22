import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class ResetsController extends GetxController {
  ResetsController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final _options = <ResetOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final options = await _contentItemsService.loadResetOptions();
      _options.assignAll(options);
    } catch (_) {
      _options.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'all';
    }
  }

  List<String> get categories {
    final values = <String>['all'];
    for (final option in _options) {
      final category = option.category.trim().toLowerCase();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }
    return values;
  }

  List<ResetOption> get options => _options;

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
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.meditation,
        nextRoute: AppRoutes.audioPlayer,
        nextArguments: {
          'track': AudioTrack(
            title: option.title,
            category: option.category,
            description: option.subtitle,
            duration: option.duration,
            assetPath: option.audioPath.isEmpty
                ? AppAssets.resetBreathReset
                : option.audioPath,
          ),
          'imagePath': AppAssets.archway,
          'minimal': true,
          'ritualFeature': RitualWrapFeature.meditation,
        },
      ).toMap(),
    );
  }
}
