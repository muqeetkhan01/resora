import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class EmailAuthController extends GetxController {
  final isSignIn = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    final mode = Get.arguments;
    isSignIn.value = mode == 'signin';
  }

  void switchMode(bool signIn) {
    isSignIn.value = signIn;
  }

  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void submit() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void forgotPassword() {
    // Get.snackbar(
    //   'Reset link',
    //   'Password reset UI placeholder. Connect your real auth flow later.',
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
