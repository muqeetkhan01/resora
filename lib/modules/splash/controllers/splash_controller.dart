import 'dart:async';

import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _session = Get.find<AppSessionController>();
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    _timer = Timer(
      const Duration(milliseconds: 3000),
      () async {
        await _session.waitUntilReady();

        if (!_session.isAuthenticated) {
          Get.offNamed(AppRoutes.welcome);
          return;
        }

        if (_session.isNewUser) {
          Get.offNamed(AppRoutes.onboarding);
          return;
        }

        Get.offNamed(AppRoutes.dashboard);
      },
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
