import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  List<ProfileOption> get options => MockContent.profileOptions;
  final affirmationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final journalLockEnabled = false.obs;

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
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
}
