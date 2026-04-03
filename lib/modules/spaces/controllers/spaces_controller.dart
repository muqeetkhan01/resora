import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class SpacesController extends GetxController {
  List<QuickActionItem> get spaces => MockContent.spaces;

  void openSpace(QuickActionItem item) {
    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  void goHome() {
    Get.find<DashboardController>().switchTab(0);
  }

  void openProfile() {
    Get.toNamed(AppRoutes.profile);
  }
}
