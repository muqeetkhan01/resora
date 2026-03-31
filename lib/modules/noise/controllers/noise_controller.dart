import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class NoiseController extends GetxController {
  final selectedCategory = 'All'.obs;

  List<String> get categories => const [
        'All',
        'Nature',
        'Brown Noise',
        'Guided Meditation',
        'Visualizations',
      ];

  List<AudioTrack> get tracks {
    if (selectedCategory.value == 'All') return MockContent.audioTracks;

    return MockContent.audioTracks
        .where((track) => track.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void openTrack(AudioTrack track) {
    Get.toNamed(AppRoutes.audioPlayer, arguments: track);
  }
}
