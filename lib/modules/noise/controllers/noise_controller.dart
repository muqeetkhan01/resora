import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class NoiseController extends GetxController {
  NoiseController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'All'.obs;
  final _remoteTracks = <AudioTrack>[].obs;

  List<AudioTrack> get _sourceTracks {
    if (_remoteTracks.isNotEmpty) {
      return _remoteTracks;
    }
    return MockContent.audioTracks;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    try {
      final tracks = await _contentItemsService.loadAudioTracks();
      if (tracks.isNotEmpty) {
        _remoteTracks.assignAll(tracks);
      }
    } catch (_) {
      _remoteTracks.clear();
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
          'ritualFeature': RitualWrapFeature.asmr,
        },
      ).toMap(),
    );
  }
}
