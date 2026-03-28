import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  List get items => MockContent.onboarding;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> next() async {
    if (currentPage.value == MockContent.onboarding.length - 1) {
      Get.offNamed(AppRoutes.welcome);
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() {
    Get.offNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
