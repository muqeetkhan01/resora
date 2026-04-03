import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class AuthEntryController extends GetxController {
  final _session = Get.find<AppSessionController>();

  void continueWithEmail() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signup');
  }

  void continueWithGoogle() {
    _session.completeAuth();
  }

  void continueWithApple() {
    _session.completeAuth();
  }

  void signIn() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signin');
  }

  void enterApp() {
    _session.completeAuth();
  }
}
