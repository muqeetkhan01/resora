import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class JournalController extends GetxController {
  final selectedMode = 0.obs;
  final currentPage = 0.obs;
  final draftController = TextEditingController();

  List<String> get modes =>
      const ['all', 'calm', 'clarity', 'relationships', 'identity'];
  String get promptOfTheDay => MockContent.journalPrompts.first;
  List<String> get prompts => const [
        'What\'s one thought that made you feel lighter today?',
        'What helped more than you expected?',
        'What felt heavier than it looked?',
      ];

  void selectMode(int index) {
    selectedMode.value = index;
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
