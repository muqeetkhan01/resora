import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _session = Get.find<AppSessionController>();
  bool _didNavigate = false;

  Future<void> continueFromSplash() async {
    if (_didNavigate) return;
    _didNavigate = true;
    await _session.waitUntilReady();

    if (!_session.isAuthenticated) {
      Get.offNamed(AppRoutes.onboarding);
      return;
    }

    Get.offNamed(AppRoutes.dashboard);
  }
}
