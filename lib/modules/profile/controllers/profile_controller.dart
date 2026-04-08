import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();
  List<ProfileOption> get options => MockContent.profileOptions;
  final affirmationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final journalLockEnabled = false.obs;

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void toggleAffirmations(bool value) {
    affirmationsEnabled.value = value;
  }

  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
  }

  void toggleJournalLock(bool value) {
    journalLockEnabled.value = value;
  }

  Future<void> openOption(ProfileOption option) async {
    if (option.route != null) {
      if (option.route == AppRoutes.welcome) {
        await _session.signOut();
        return;
      }
      Get.toNamed(option.route!);
    }
  }

  void openMindfulness() {
    Get.toNamed(AppRoutes.mindfulness);
  }

  void openCommunity() {
    Get.toNamed(AppRoutes.community);
  }
}
