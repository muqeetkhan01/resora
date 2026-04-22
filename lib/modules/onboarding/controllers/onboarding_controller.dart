import 'package:flutter/widgets.dart';
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

  final nameController = TextEditingController();
  final currentIndex = 0.obs;
  final _remoteSlides = <OnboardingItem>[].obs;

  List<OnboardingItem> get slides => _remoteSlides;

  bool get isNameStep => currentIndex.value >= slides.length;

  int get stepCount => slides.length + 1;

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    try {
      final slides = await _contentItemsService.loadOnboardingItems();
      _remoteSlides.assignAll(slides);
    } catch (_) {
      _remoteSlides.clear();
    }
  }

  void next() {
    if (isNameStep) {
      finish();
      return;
    }

    currentIndex.value += 1;
  }

  void back() {
    if (currentIndex.value > 0) {
      currentIndex.value -= 1;
    }
  }

  Future<void> finish() async {
    final value = nameController.text.trim();
    if (value.isEmpty) {
      return;
    }

    await _session.saveName(value);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  Future<void> skip() async {
    final fallback =
        _session.displayName == 'there' ? 'friend' : _session.displayName;
    await _session.saveName(fallback);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
