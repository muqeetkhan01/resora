import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';

class CommunityController extends GetxController {
  CommunityController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'All'.obs;
  final _posts = <CommunityPost>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _contentItemsService.loadCommunityPosts();
      _posts.assignAll(posts);
    } catch (_) {
      _posts.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'All';
    }
  }

  List<String> get categories {
    final values = <String>['All'];
    for (final post in _posts) {
      final category = post.category.trim();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }
    return values;
  }

  List<CommunityPost> get posts {
    if (selectedCategory.value == 'All') return _posts;

    return _posts
        .where((post) => post.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
