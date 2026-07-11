import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class JournalController extends GetxController {
  JournalController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedCategory = 'all'.obs;
  final currentPage = 0.obs;
  final draftController = TextEditingController();
  final isLoading = true.obs;
  final _remotePrompts = <JournalPrompt>[].obs;

  List<JournalPrompt> get _sourcePrompts => _remotePrompts;
  bool get hasPremiumAccess =>
      Get.isRegistered<SubscriptionService>() &&
      Get.find<SubscriptionService>().isPremium.value;

  @override
  void onInit() {
    super.onInit();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    isLoading.value = true;
    try {
      final prompts = await _contentItemsService.loadJournalPrompts();
      _remotePrompts.assignAll(prompts);
    } catch (_) {
      _remotePrompts.clear();
    } finally {
      isLoading.value = false;
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
    if (!hasPremiumAccess) {
      Get.toNamed(AppRoutes.subscription);
      return;
    }

    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.journal,
        nextRoute: AppRoutes.journalEditor,
        nextArguments: entry ?? prompt,
      ).toMap(),
    );
  }

  void openPrompt(JournalPrompt prompt) {
    openEditor(prompt: prompt.prompt);
  }

  void openHistory() {
    Get.toNamed(AppRoutes.journalHistory);
  }

  @override
  void onClose() {
    draftController.dispose();
    super.onClose();
  }
}
