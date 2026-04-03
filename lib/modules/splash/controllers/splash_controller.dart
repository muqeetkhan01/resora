import 'dart:async';

import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onReady() {
    super.onReady();
    _timer = Timer(
      const Duration(milliseconds: 2800),
      () => Get.offNamed(AppRoutes.onboarding),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
