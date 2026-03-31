import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class PremiumController extends GetxController {
  final selectedPlan = 1.obs;

  List<PremiumPlan> get plans => MockContent.premiumPlans;

  void selectPlan(int index) {
    selectedPlan.value = index;
  }

  void startTrial() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void restorePurchases() {
    Get.back();
  }
}
