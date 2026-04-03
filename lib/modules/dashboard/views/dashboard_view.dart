import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/app_bottom_nav.dart';
import '../../chat/views/chat_view.dart';
import '../../home/views/home_view.dart';
import '../../spaces/views/spaces_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeView(),
      ChatView(rootTab: true),
      SpacesView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.switchTab,
        ),
      ),
    );
  }
}
