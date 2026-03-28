import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

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

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
