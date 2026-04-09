import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class MindfulnessController extends GetxController {
  final selectedTab = 0.obs;

  List<String> get tabs => MockContent.mindfulnessTabs;

  List<MindfulnessSession> get sessions => MockContent.mindfulnessSessions
      .where((session) => session.type == tabs[selectedTab.value])
      .toList();

  @override
  void onInit() {
    super.onInit();
    final initialTab = Get.arguments;
    if (initialTab is int && initialTab >= 0 && initialTab < tabs.length) {
      selectedTab.value = initialTab;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void openSession(MindfulnessSession session) {
    if (session.isPremium) {
      Get.toNamed(AppRoutes.premium);
      return;
    }

    Get.toNamed(AppRoutes.mindfulnessDetail, arguments: session);
  }

  void playSession(MindfulnessSession session) {
    final track = AudioTrack(
      title: session.title,
      category: session.type,
      description: session.subtitle,
      duration: session.length,
      assetPath: _assetForSession(session),
      isPremium: session.isPremium,
    );
    Get.toNamed(AppRoutes.audioPlayer, arguments: track);
  }

  String _assetForSession(MindfulnessSession session) {
    switch (session.title) {
      case 'Soft rain on leaves':
        return AppAssets.ambientSoftRain;
      case 'Brown noise for the background':
        return AppAssets.ambientBrownNoise;
      case 'Five-minute guided exhale':
        return AppAssets.guidedExhale;
      case 'Parenting calm visualization':
        return AppAssets.guidedParentingCalm;
      default:
        return AppAssets.guidedExhale;
    }
  }
}
