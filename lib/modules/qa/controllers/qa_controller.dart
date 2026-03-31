import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class QaController extends GetxController {
  final selectedCategory = 'All'.obs;
  final expandedIndex = (-1).obs;
  final query = ''.obs;
  final searchController = TextEditingController();

  List<String> get categories => MockContent.categories;

  List<QaItem> get filtered {
    return MockContent.qas.where((item) {
      final matchesCategory = selectedCategory.value == 'All' ||
          item.category == selectedCategory.value;
      final matchesQuery = query.value.isEmpty ||
          item.question.toLowerCase().contains(query.value.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    expandedIndex.value = -1;
  }

  void setQuery(String value) {
    query.value = value;
  }

  void toggleExpanded(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  void openChat() {
    Get.toNamed(AppRoutes.chat);
  }

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }

  void openRelatedSpace(QaItem item) {
    switch (item.category) {
      case 'Parenting':
        Get.toNamed(AppRoutes.rehearse);
        break;
      case 'Work Stress':
      case 'Body / Regulation':
        Get.toNamed(AppRoutes.resets);
        break;
      case 'Relationships':
        Get.toNamed(AppRoutes.chat);
        break;
      default:
        Get.toNamed(AppRoutes.spaces);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
