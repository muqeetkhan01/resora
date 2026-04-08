import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../widgets/app_snackbar.dart';

class EmailAuthController extends GetxController {
  final _session = Get.find<AppSessionController>();
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _uppercasePattern = RegExp(r'[A-Z]');
  static final RegExp _lowercasePattern = RegExp(r'[a-z]');
  static final RegExp _numberPattern = RegExp(r'\d');

  final isSignIn = false.obs;
  final isSubmitting = false.obs;
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

  Future<void> submit() async {
    if (isSubmitting.value) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final validationMessage = _validateInputs(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      isSignIn: isSignIn.value,
    );
    if (validationMessage != null) {
      _showError(validationMessage);
      return;
    }

    try {
      isSubmitting.value = true;
      if (isSignIn.value) {
        await _session.signInWithEmail(email: email, password: password);
      } else {
        await _session.signUpWithEmail(
          email: email,
          password: password,
        );
      }
      _session.completeAuth();
    } catch (error, stackTrace) {
      if (error is FirebaseAuthException) {
        debugPrint(
          'FirebaseAuthException during email auth: '
          'code=${error.code}, message=${error.message}, email=${error.email}, '
          'credential=${error.credential}, plugin=${error.plugin}',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError(_session.describeError(error));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (isSubmitting.value) {
      return;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError(
          'Enter your email first so we know where to send the reset link.');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    try {
      isSubmitting.value = true;
      await _session.sendPasswordReset(email);
      showAppSnackbar(
        'Reset email sent',
        'If this email uses password sign in, you will receive a reset link shortly.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      if (error is FirebaseAuthException) {
        debugPrint(
          'FirebaseAuthException during password reset: '
          'code=${error.code}, message=${error.message}, email=${error.email}, '
          'credential=${error.credential}, plugin=${error.plugin}',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError(_session.describeError(error));
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showError(String message) {
    showAppSnackbar(
      'Auth error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String? _validateInputs({
    required String email,
    required String password,
    required String confirmPassword,
    required bool isSignIn,
  }) {
    if (email.isEmpty) {
      return 'Please enter your email.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (isSignIn) {
      return null;
    }

    if (password.length < 10) {
      return 'Weak password. Try a stronger one with at least 10 characters.';
    }
    if (!_uppercasePattern.hasMatch(password)) {
      return 'Add at least one uppercase letter to your password.';
    }
    if (!_lowercasePattern.hasMatch(password)) {
      return 'Add at least one lowercase letter to your password.';
    }
    if (!_numberPattern.hasMatch(password)) {
      return 'Add at least one number to your password.';
    }
    if (password != confirmPassword) {
      return 'Your passwords do not match.';
    }

    return null;
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
