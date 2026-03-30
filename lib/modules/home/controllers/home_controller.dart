import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  List<QuickActionItem> get quickActions => MockContent.quickActions;
  HomeSnippet get primary => MockContent.homePrimary;
  String get affirmation => MockContent.dailyAffirmation;
  JournalEntry get recentJournal => MockContent.recentJournal;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void openHelpNow() {
    Get.find<DashboardController>().switchTab(1);
  }

  void openJournal() {
    Get.find<DashboardController>().switchTab(3);
  }

  void openQuickAction(QuickActionItem item) {
    if (item.dashboardIndex != null) {
      Get.find<DashboardController>().switchTab(item.dashboardIndex!);
      return;
    }

    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  void openProfile() {
    Get.find<DashboardController>().openProfile();
  }
}
