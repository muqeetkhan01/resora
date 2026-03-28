import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class AffirmationsController extends GetxController {
  final selectedCategory = 'All'.obs;
  final saved = <String>{'For Mothers'}.obs;

  List<String> get categories =>
      ['All', ...MockContent.affirmations.map((e) => e.category).toSet()];

  List<AffirmationItem> get filtered {
    if (selectedCategory.value == 'All') return MockContent.affirmations;

    return MockContent.affirmations
        .where((item) => item.category == selectedCategory.value)
        .toList();
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
