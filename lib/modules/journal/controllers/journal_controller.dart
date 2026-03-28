import 'package:get/get.dart';

import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';

class JournalController extends GetxController {
  final moods = ['Calm', 'Overwhelmed', 'Grateful', 'Reflective', 'Hopeful'];
  final selectedMood = 'Calm'.obs;

  String get promptOfTheDay => MockContent.journalPrompts.first;
  List<JournalEntry> get entries => MockContent.journalEntries;

  void selectMood(String mood) {
    selectedMood.value = mood;
  }
}
