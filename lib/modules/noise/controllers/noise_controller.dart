import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/content_items_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class NoiseController extends GetxController {
  NoiseController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'All'.obs;
  final isLoading = true.obs;
  final _remoteTracks = <AudioTrack>[].obs;

  List<AudioTrack> get _sourceTracks => _remoteTracks;
  int get totalTrackCount => _sourceTracks.length;
  bool get hasPremiumAccess =>
      Get.isRegistered<SubscriptionService>() &&
      Get.find<SubscriptionService>().isPremium.value;

  @override
  void onInit() {
    super.onInit();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    isLoading.value = true;
    try {
      final tracks = await _contentItemsService.loadAudioTracks();
      _remoteTracks.assignAll(tracks);
    } catch (_) {
      _remoteTracks.clear();
    } finally {
      isLoading.value = false;
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  List<String> get categories {
    final values = <String>['All'];
    for (final track in _sourceTracks) {
      final category = track.category.trim();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }
    return values;
  }

  List<AudioTrack> get tracks {
    if (selectedCategory.value == 'All') return _sourceTracks;

    return _sourceTracks
        .where((track) => track.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void openTrack(AudioTrack track) {
    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.asmr,
        nextRoute: AppRoutes.audioPlayer,
        nextArguments: {
          'track': track,
          'imagePath': track.imagePath.isEmpty
              ? _fallbackImageFor(track)
              : track.imagePath,
          'ritualFeature': RitualWrapFeature.asmr,
          'previewOnly': !hasPremiumAccess,
        },
      ).toMap(),
    );
  }

  String _fallbackImageFor(AudioTrack track) {
    final category = track.category.toLowerCase();
    if (category.contains('brown')) return AppAssets.spaceRoom;
    if (category.contains('guided')) return AppAssets.archway;
    if (category.contains('visual')) return AppAssets.curtainLight;
    if (category.contains('nature')) return AppAssets.splashWaterfall;
    return AppAssets.spaceRoom;
  }
}
