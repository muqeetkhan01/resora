import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class CommunityController extends GetxController {
  final selectedCategory = 'All'.obs;

  List<String> get categories =>
      ['All', 'Daily Wins', 'Mindfulness', 'Questions', 'Healing'];

  List<CommunityPost> get posts {
    if (selectedCategory.value == 'All') return MockContent.communityPosts;

    return MockContent.communityPosts
        .where((post) => post.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
