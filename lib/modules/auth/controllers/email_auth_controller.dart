import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';

class EmailAuthController extends GetxController {
  final _session = Get.find<AppSessionController>();
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
    _session.completeAuth();
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
