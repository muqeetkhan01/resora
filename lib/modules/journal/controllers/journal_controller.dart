import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class JournalController extends GetxController {
  final selectedMode = 0.obs;
  final draftController = TextEditingController();

  List<String> get modes => const ['Prompted', 'Free Write', 'Guided'];
  String get promptOfTheDay => MockContent.journalPrompts.first;
  List<JournalEntry> get entries => MockContent.journalEntries;

  void selectMode(int index) {
    selectedMode.value = index;
  }

  void openEditor({JournalEntry? entry}) {
    Get.toNamed(AppRoutes.journalEditor, arguments: entry);
  }

  @override
  void onClose() {
    draftController.dispose();
    super.onClose();
  }
}
