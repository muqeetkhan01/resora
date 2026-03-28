import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class AuthEntryController extends GetxController {
  void enterApp() {
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
