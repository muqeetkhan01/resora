import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class AuthEntryController extends GetxController {
  void continueWithEmail() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signup');
  }

  void continueWithGoogle() {
    enterApp();
  }

  void continueWithApple() {
    enterApp();
  }

  void signIn() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signin');
  }

  void enterApp() {
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
