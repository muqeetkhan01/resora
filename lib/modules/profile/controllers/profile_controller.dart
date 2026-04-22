import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();

  final affirmationsEnabled = true.obs;
  final journalLockEnabled = false.obs;
  final isPremium = false.obs;
  final activePlan = 'free'.obs;
  final journalPin = RxnString();

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void toggleAffirmations(bool value) {
    affirmationsEnabled.value = value;
  }

  void toggleJournalLock(bool value) {
    journalLockEnabled.value = value;
    if (!value) {
      journalPin.value = null;
    }
  }

  void openSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  void openJournalLock() {
    Get.toNamed(AppRoutes.journalLock);
  }

  void openHelpSupport() {
    Get.toNamed(AppRoutes.helpSupport);
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  Future<void> signOut() async {
    await _session.signOut();
  }

  bool get hasJournalPin => (journalPin.value ?? '').isNotEmpty;

  void setJournalPin(String pin) {
    journalPin.value = pin;
    journalLockEnabled.value = true;
  }

  void clearJournalPin() {
    journalPin.value = null;
    journalLockEnabled.value = false;
  }

  void setPlan(String plan) {
    activePlan.value = plan;
    isPremium.value = plan == 'premium';
  }
}
