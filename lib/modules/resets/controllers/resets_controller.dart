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
  final isLoading = true.obs;
  final _options = <ResetOption>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    isLoading.value = true;
    try {
      final options = await _contentItemsService.loadResetOptions();
      _options.assignAll(options);
    } catch (_) {
      _options.clear();
    } finally {
      isLoading.value = false;
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
    final audioPath =
        option.audioPath.isEmpty ? _fallbackAudioFor(option) : option.audioPath;
    final imagePath =
        option.imagePath.isEmpty ? _fallbackImageFor(option) : option.imagePath;

    final playerArgs = {
      'track': AudioTrack(
        title: option.title,
        category: option.category,
        description: option.subtitle,
        duration: option.duration,
        assetPath: audioPath,
        imagePath: imagePath,
      ),
      'imagePath': imagePath,
      'minimal': true,
      'ritualFeature': RitualWrapFeature.meditation,
    };

    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.meditation,
        nextRoute: AppRoutes.audioPlayer,
        nextArguments: playerArgs,
      ).toMap(),
    );
  }

  String _fallbackAudioFor(ResetOption option) {
    final title = option.title.toLowerCase();
    final category = option.category.toLowerCase();
    if (title.contains('step away')) return AppAssets.resetStepAway;
    if (title.contains('box')) return AppAssets.resetBoxBreath;
    if (title.contains('cold')) return AppAssets.resetColdWater;
    if (title.contains('54321') || title.contains('5-4-3')) {
      return AppAssets.resetGroundFiveFourThreeTwoOne;
    }
    if (category.contains('release')) return AppAssets.resetStepAway;
    if (category.contains('clarity')) return AppAssets.resetBoxBreath;
    if (category.contains('restore')) return AppAssets.resetColdWater;
    return AppAssets.resetBreathReset;
  }

  String _fallbackImageFor(ResetOption option) {
    final category = option.category.toLowerCase();
    if (category.contains('release')) return AppAssets.spaceGarden;
    if (category.contains('clarity')) return AppAssets.splashWaterfall;
    if (category.contains('connect')) return AppAssets.curtainLight;
    if (category.contains('restore')) return AppAssets.splashLivingRoom;
    return AppAssets.archway;
  }
}
