import 'dart:async';

import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/user_generated_content_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';

class JournalHistoryController extends GetxController {
  JournalHistoryController({
    UserGeneratedContentService? userGeneratedContentService,
  }) : _userGeneratedContentService =
            userGeneratedContentService ?? UserGeneratedContentService();

  final _session = Get.find<AppSessionController>();
  final UserGeneratedContentService _userGeneratedContentService;

  final entries = <JournalEntry>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;

  @override
  void onInit() {
    super.onInit();
    _startSync();
  }

  Future<void> _startSync() async {
    final uid = _session.firebaseUser?.uid;
    if (uid == null) {
      isLoading.value = false;
      errorMessage.value = 'Sign in to view journal history.';
      return;
    }

    _entriesSubscription?.cancel();
    _entriesSubscription =
        _userGeneratedContentService.watchJournalEntries(uid).listen(
      (rows) {
        entries.assignAll(rows);
        errorMessage.value = null;
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        errorMessage.value = 'Could not load journal history right now.';
      },
    );
  }

  Future<void> openEntry(JournalEntry entry) async {
    final hasPremium = Get.isRegistered<SubscriptionService>() &&
        Get.find<SubscriptionService>().isPremium.value;
    if (!hasPremium) {
      Get.toNamed(AppRoutes.subscription);
      return;
    }

    Get.toNamed(AppRoutes.journalEditor, arguments: entry);
  }

  void startNewEntry() {
    Get.toNamed(AppRoutes.journal);
  }

  void showLoadError() {
    showAppSnackbar(
      'History unavailable',
      'Could not load journal history right now.',
    );
  }

  @override
  void onClose() {
    _entriesSubscription?.cancel();
    super.onClose();
  }
}
