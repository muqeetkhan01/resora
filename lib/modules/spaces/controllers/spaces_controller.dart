import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class SpacesController extends GetxController {
  final showingLibrary = false.obs;
  final selectedCheckIn = 'Select...'.obs;
  final selectedSpaceTitle = ''.obs;

  List<QuickActionItem> get spaces => MockContent.spaces;
  List<SupportCardItem> get supportCards => MockContent.supportCards;
  List<String> get checkInOptions => const [
        'Select...',
        'Overwhelmed',
        'Tired',
        'Anxious',
        'Need clarity',
      ];

  void openSpace(QuickActionItem item) {
    if (item.route == AppRoutes.normal) {
      selectedSpaceTitle.value = item.title;
      showingLibrary.value = true;
      return;
    }

    if (item.dashboardIndex != null && Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().switchTab(item.dashboardIndex!);
      return;
    }

    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  void goHome() {
    Get.find<DashboardController>().switchTab(0);
  }

  void backToList() {
    showingLibrary.value = false;
  }

  void openProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  void selectCheckIn(String? value) {
    if (value == null) return;
    selectedCheckIn.value = value;
  }

  void createItem() {
    Get.toNamed(AppRoutes.community);
  }

  void openLibraryCard(SupportCardItem item) {
    Get.toNamed(
      AppRoutes.normal,
      arguments: item.title,
    );
  }
}
