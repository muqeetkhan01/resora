import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final currentStep = 0.obs;
  final nameController = TextEditingController();
  final selectedGoals = <String>{}.obs;
  final notificationsEnabled = false.obs;

  List<GoalOption> get goals => MockContent.goals;
  int get totalSteps => 5;

  void next() {
    if (currentStep.value == totalSteps - 1) {
      finish();
      return;
    }

    currentStep.value += 1;
  }

  void finish() {
    Get.offAllNamed(AppRoutes.welcome);
  }

  void skip() {
    finish();
  }

  void toggleGoal(String title) {
    if (selectedGoals.contains(title)) {
      selectedGoals.remove(title);
    } else {
      selectedGoals.add(title);
    }
    selectedGoals.refresh();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
