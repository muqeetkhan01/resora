import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  List<ProfileOption> get options => MockContent.profileOptions;

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }
}
