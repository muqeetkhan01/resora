import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class JournalController extends GetxController {
  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final draftController = TextEditingController();

  List<String> get categories =>
      const ['all', 'ground', 'release', 'clarity', 'connect', 'restore'];
  JournalPrompt get promptOfTheDay => MockContent.journalPrompts.first;
  List<JournalPrompt> get prompts {
    if (selectedCategory.value == 'all') {
      return MockContent.journalPrompts;
    }

    return MockContent.journalPrompts
        .where((prompt) => prompt.category == selectedCategory.value)
        .toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    currentPage.value = 0;
  }

  void setCurrentPage(int index) {
    currentPage.value = index;
  }

  void openEditor({JournalEntry? entry, String? prompt}) {
    Get.toNamed(AppRoutes.journalEditor, arguments: entry ?? prompt);
  }

  @override
  void onClose() {
    draftController.dispose();
    super.onClose();
  }
}
