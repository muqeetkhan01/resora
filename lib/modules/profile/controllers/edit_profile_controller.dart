import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';

class EditProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: _session.userName ?? '');
    emailController = TextEditingController(text: 'amber@example.com');
    passwordController = TextEditingController(text: 'password123');
  }

  void saveProfile() {
    _session.saveName(nameController.text);
    Get.back();
    Get.snackbar(
      'Profile updated',
      'Profile UI saved locally for now. Connect backend later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
