import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class QaController extends GetxController {
  QaController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'All'.obs;
  final expandedIndex = (-1).obs;
  final query = ''.obs;
  final searchController = TextEditingController();
  final _items = <QaItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadQaItems();
  }

  Future<void> _loadQaItems() async {
    try {
      final items = await _contentItemsService.loadQaItems();
      _items.assignAll(items);
    } catch (_) {
      _items.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  List<String> get categories {
    final values = <String>['All'];
    for (final item in _items) {
      final category = item.category.trim();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }
    return values;
  }

  List<QaItem> get filtered {
    return _items.where((item) {
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
