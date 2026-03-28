import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/app_background.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../../community/views/community_view.dart';
import '../../home/views/home_view.dart';
import '../../journal/views/journal_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeView(),
      JournalView(),
      CommunityView(),
      ProfileView(),
    ];

    return Obx(
      () => AppBackground(
        bottomNavigationBar: AppBottomNav(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.switchTab,
        ),
        child: IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
    );
  }
}
