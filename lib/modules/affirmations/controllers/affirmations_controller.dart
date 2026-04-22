import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';

class AffirmationsController extends GetxController {
  AffirmationsController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'All'.obs;
  final saved = <String>{}.obs;
  final _items = <AffirmationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAffirmations();
  }

  Future<void> _loadAffirmations() async {
    try {
      final items = await _contentItemsService.loadAffirmations();
      _items.assignAll(items);
    } catch (_) {
      _items.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  List<String> get categories =>
      ['All', ..._items.map((e) => e.category).toSet()];

  List<AffirmationItem> get filtered {
    if (selectedCategory.value == 'All') return _items;

    return _items
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  AffirmationItem? get hero {
    if (_items.isEmpty) {
      return null;
    }
    return _items.first;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleSaved(AffirmationItem item) {
    if (saved.contains(item.text)) {
      saved.remove(item.text);
    } else {
      saved.add(item.text);
    }
  }
}
