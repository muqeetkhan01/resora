import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class JournalController extends GetxController {
  final selectedMode = 0.obs;

  List<String> get modes => const ['Prompted', 'Free Write', 'Guided'];
  String get promptOfTheDay => MockContent.journalPrompts.first;
  List<JournalEntry> get entries => MockContent.journalEntries;

  void selectMode(int index) {
    selectedMode.value = index;
  }
}
