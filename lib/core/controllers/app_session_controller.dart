import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class AppSessionController extends GetxController {
  final _userName = RxnString();

  String? get userName => _userName.value;
  bool get isNewUser =>
      _userName.value == null || _userName.value!.trim().isEmpty;

  String get displayName {
    final value = _userName.value?.trim();
    return value == null || value.isEmpty ? 'there' : value;
  }

  void completeAuth() {
    if (isNewUser) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    Get.offAllNamed(AppRoutes.dashboard);
  }

  void saveName(String value) {
    _userName.value = value.trim();
  }

  void signOut() {
    _userName.value = null;
    Get.offAllNamed(AppRoutes.welcome);
  }
}
