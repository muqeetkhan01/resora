import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';

class PremiumController extends GetxController {
  PremiumController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;
  final _subscriptions = Get.find<SubscriptionService>();

  final selectedPlan = 1.obs;
  final _plans = <PremiumPlan>[].obs;

  List<PremiumPlan> get plans => _plans;

  @override
  void onInit() {
    super.onInit();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _contentItemsService.loadPremiumPlans();
      _plans.assignAll(plans);
    } catch (_) {
      _plans.clear();
    }

    if (_plans.isEmpty) {
      selectedPlan.value = 0;
      return;
    }

    selectedPlan.value = selectedPlan.value.clamp(0, _plans.length - 1);
  }

  void selectPlan(int index) {
    if (index < 0 || index >= plans.length) {
      return;
    }
    selectedPlan.value = index;
  }

  void startTrial() {
    Get.toNamed(AppRoutes.subscription);
  }

  bool get canShowRestore => _subscriptions.canShowRestore;

  bool get isBusy =>
      _subscriptions.isLoading.value ||
      _subscriptions.isPurchasing.value ||
      _subscriptions.isRestoring.value;

  Future<void> restorePurchases() async {
    if (!canShowRestore || isBusy) {
      return;
    }

    try {
      final restored = await _subscriptions.restorePurchases();
      showAppSnackbar(
        restored ? 'Restored' : 'Nothing active found',
        restored
            ? 'Your Resora premium access is active.'
            : 'We did not find an active subscription for this account.',
      );
    } on SubscriptionException catch (error) {
      showAppSnackbar('Could not restore', error.message);
    } catch (_) {
      showAppSnackbar(
        'Could not restore',
        'Please try again in a moment.',
      );
    }
  }
}
