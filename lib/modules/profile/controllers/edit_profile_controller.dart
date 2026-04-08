import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../widgets/app_snackbar.dart';

class EditProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: _session.userName ?? '');
    emailController = TextEditingController(text: _session.email ?? '');
  }

  Future<void> saveProfile() async {
    if (isSaving.value) {
      return;
    }

    try {
      isSaving.value = true;
      final message = await _session.updateProfile(
        displayName: nameController.text,
        email: emailController.text,
      );
      Get.back();
      showAppSnackbar(
        'Profile updated',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      showAppSnackbar(
        'Update failed',
        _session.describeError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
