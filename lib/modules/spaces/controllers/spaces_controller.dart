import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class SpacesController extends GetxController {
  SpacesController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;
  final _spaces = <QuickActionItem>[].obs;
  final _routeHasContent = <String, bool>{}.obs;

  List<QuickActionItem> get spaces => _spaces;

  @override
  void onInit() {
    super.onInit();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    try {
      final items = await _contentItemsService.loadSpaces();
      _spaces.assignAll(items);
    } catch (_) {
      _spaces.clear();
    }

    await _refreshRouteAvailability();
  }

  Future<void> _refreshRouteAvailability() async {
    Future<bool> has<T>(Future<List<T>> Function() load) async {
      try {
        final data = await load();
        return data.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    _routeHasContent[AppRoutes.chat] = true;
    _routeHasContent[AppRoutes.normal] =
        await has(_contentItemsService.loadNormalTopics);
    _routeHasContent[AppRoutes.resets] =
        await has(_contentItemsService.loadResetOptions);
    _routeHasContent[AppRoutes.noise] =
        await has(_contentItemsService.loadAudioTracks);
    _routeHasContent[AppRoutes.terms] =
        await has(_contentItemsService.loadKeyTerms);
    _routeHasContent[AppRoutes.rehearse] =
        await has(_contentItemsService.loadRehearsalScenarios);
    _routeHasContent[AppRoutes.journal] =
        await has(_contentItemsService.loadJournalPrompts);
  }

  QuickActionItem? findSpaceByRoute(String route) {
    for (final item in _spaces) {
      if (item.route == route) {
        return item;
      }
    }
    return null;
  }

  QuickActionItem? findSpaceByTitle(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final item in _spaces) {
      if (item.title.toLowerCase().contains(normalized)) {
        return item;
      }
    }
    return null;
  }

  bool hasContentForRoute(String route) {
    if (route.trim().isEmpty) {
      return false;
    }
    return _routeHasContent[route] ?? false;
  }

  Future<void> openSpace(QuickActionItem item) async {
    if (item.route.trim().isEmpty) {
      return;
    }
    if (item.route == AppRoutes.journal) {
      final profile = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());
      final unlocked = await profile.ensureJournalUnlocked();
      if (!unlocked) {
        return;
      }

      Get.toNamed(
        AppRoutes.ritualWrap,
        arguments: RitualWrapArgs.entry(
          feature: RitualWrapFeature.journal,
          nextRoute: AppRoutes.journal,
        ).toMap(),
      );
      return;
    }

    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  void goHome() {
    Get.find<DashboardController>().switchTab(0);
  }

  void openProfile() {
    Get.toNamed(AppRoutes.profile);
  }
}
