import 'package:get/get.dart';

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
    Get.toNamed(AppRoutes.mindfulnessDetail, arguments: session);
  }
}
