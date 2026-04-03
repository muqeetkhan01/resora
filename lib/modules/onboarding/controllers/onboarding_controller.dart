import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _session = Get.find<AppSessionController>();
  final nameController = TextEditingController();

  void finish() {
    final value = nameController.text.trim();
    if (value.isEmpty) {
      return;
    }

    _session.saveName(value);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void skip() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
