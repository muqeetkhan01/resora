import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _session = Get.find<AppSessionController>();

  final nameController = TextEditingController();
  final currentIndex = 0.obs;

  List<OnboardingItem> get slides => MockContent.onboarding;

  bool get isNameStep => currentIndex.value >= slides.length;

  int get stepCount => slides.length + 1;

  void next() {
    if (isNameStep) {
      finish();
      return;
    }

    currentIndex.value += 1;
  }

  void back() {
    if (currentIndex.value > 0) {
      currentIndex.value -= 1;
    }
  }

  Future<void> finish() async {
    final value = nameController.text.trim();
    if (value.isEmpty) {
      return;
    }

    await _session.saveName(value);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  Future<void> skip() async {
    final fallback =
        _session.displayName == 'there' ? 'friend' : _session.displayName;
    await _session.saveName(fallback);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
