import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class JournalController extends GetxController {
  JournalController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final draftController = TextEditingController();
  final _remotePrompts = <JournalPrompt>[].obs;

  List<JournalPrompt> get _sourcePrompts {
    if (_remotePrompts.isNotEmpty) {
      return _remotePrompts;
    }
    return MockContent.journalPrompts;
  }

  @override
  void onInit() {
    super.onInit();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    try {
      final prompts = await _contentItemsService.loadJournalPrompts();
      if (prompts.isNotEmpty) {
        _remotePrompts.assignAll(prompts);
      } else {
        _remotePrompts.clear();
      }
    } catch (_) {
      _remotePrompts.clear();
    }

    if (!categories.contains(selectedCategory.value)) {
      selectedCategory.value = 'all';
    }
  }

  List<String> get categories {
    final values = <String>['all'];

    for (final prompt in _sourcePrompts) {
      final category = prompt.category.trim().toLowerCase();
      if (category.isEmpty || values.contains(category)) {
        continue;
      }
      values.add(category);
    }

    return values;
  }

  JournalPrompt get promptOfTheDay {
    if (_sourcePrompts.isNotEmpty) {
      return _sourcePrompts.first;
    }
    return const JournalPrompt(
      category: 'ground',
      prompt: 'What helped more than you expected today?',
    );
  }

  List<JournalPrompt> get prompts {
    if (selectedCategory.value == 'all') {
      return _sourcePrompts;
    }

    final selected = selectedCategory.value.trim().toLowerCase();
    return _sourcePrompts
        .where((prompt) => prompt.category.trim().toLowerCase() == selected)
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
