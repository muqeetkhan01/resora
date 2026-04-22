import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class PremiumController extends GetxController {
  PremiumController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

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
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void restorePurchases() {
    Get.back();
  }
}
