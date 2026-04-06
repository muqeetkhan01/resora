import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../data/mock/mock_content.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  final _session = Get.find<AppSessionController>();

  String get userName => _session.displayName;
  String get affirmation => MockContent.dailyAffirmation;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void openHelpNow() {
    Get.toNamed(AppRoutes.chat);
  }

  void openTalk() {
    Get.toNamed(AppRoutes.chat);
  }

  void openJournal() {
    Get.toNamed(AppRoutes.journal);
  }

  void openNoise() {
    Get.toNamed(AppRoutes.noise);
  }

  void openRehearse() {
    Get.toNamed(AppRoutes.rehearse);
  }

  void openSpaces() {
    Get.find<DashboardController>().switchTab(2);
  }

  void openProfile() {
    Get.find<DashboardController>().openProfile();
  }

  void openInfo() {
    Get.toNamed(AppRoutes.terms);
  }

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }
}
