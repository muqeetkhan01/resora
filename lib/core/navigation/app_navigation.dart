import 'package:get/get.dart';

import '../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../routes/app_routes.dart';

abstract final class AppNavigation {
  static void openTalkTab() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().switchTab(1);
      if (Get.currentRoute != AppRoutes.dashboard) {
        Get.offAllNamed(AppRoutes.dashboard, arguments: 1);
      }
      return;
    }

    Get.offAllNamed(AppRoutes.dashboard, arguments: 1);
  }
}
