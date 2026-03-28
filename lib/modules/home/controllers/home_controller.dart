import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  List<QuickActionItem> get quickActions => MockContent.quickActions;

  List<String> get recentItems => const [
        'Morning exhale meditation',
        'Repair after rupture journal prompt',
        'For Mothers affirmation',
      ];

  String get quote =>
      'Softness is not the absence of strength. It is strength that knows how to stay open.';

  void openQuickAction(QuickActionItem item) {
    if (item.dashboardIndex != null) {
      Get.find<DashboardController>().switchTab(item.dashboardIndex!);
      return;
    }

    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }
}
