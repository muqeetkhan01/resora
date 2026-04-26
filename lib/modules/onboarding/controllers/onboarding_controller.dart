import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final _session = Get.find<AppSessionController>();
  final ContentItemsService _contentItemsService;

  final currentIndex = 0.obs;
  final _remoteSlides = <OnboardingItem>[].obs;

  List<OnboardingItem> get slides => _remoteSlides;
  bool get hasSlides => slides.isNotEmpty;
  bool get isLastSlide => !hasSlides || currentIndex.value >= slides.length - 1;

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    if (_session.isAuthenticated) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }

    try {
      final items = await _contentItemsService.loadOnboardingItems();
      _remoteSlides.assignAll(items);
    } catch (_) {
      _remoteSlides.clear();
    }

    if (!hasSlides) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }

    if (currentIndex.value >= slides.length) {
      currentIndex.value = 0;
    }
  }

  void next() {
    if (isLastSlide) {
      continueToAuth();
      return;
    }
    currentIndex.value += 1;
  }

  void back() {
    if (currentIndex.value <= 0) {
      return;
    }
    currentIndex.value -= 1;
  }

  void skip() {
    continueToAuth();
  }

  void continueToAuth() {
    Get.offAllNamed(AppRoutes.welcome);
  }
}
