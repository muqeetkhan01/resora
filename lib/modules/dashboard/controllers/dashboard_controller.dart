import 'package:get/get.dart';

class DashboardController extends GetxController {
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final initialIndex = Get.arguments;
    if (initialIndex is int) {
      selectedIndex.value = initialIndex.clamp(0, 3);
    }
  }

  void switchTab(int index) {
    selectedIndex.value = index;
  }
}
