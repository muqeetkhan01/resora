import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class SpacesController extends GetxController {
  List<QuickActionItem> get spaces => MockContent.spaces;

  void openSpace(QuickActionItem item) {
    if (item.dashboardIndex != null) {
      Get.offNamed(AppRoutes.dashboard, arguments: item.dashboardIndex);
      return;
    }

    Get.toNamed(item.route, arguments: item.routeArguments);
  }
}
