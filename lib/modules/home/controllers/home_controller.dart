import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';
import '../../../routes/app_routes.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeController extends GetxController {
  HomeController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final _session = Get.find<AppSessionController>();
  final ContentItemsService _contentItemsService;
  final _quickActions = <QuickActionItem>[].obs;
  final _routeHasContent = <String, bool>{}.obs;
  final dailyAffirmation = ''.obs;

  String get userName => _session.displayName;
  List<QuickActionItem> get quickActions => _quickActions;

  @override
  void onInit() {
    super.onInit();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final actions = await _contentItemsService.loadQuickActions();
      _quickActions.assignAll(actions);
    } catch (_) {
      _quickActions.clear();
    }

    try {
      dailyAffirmation.value = await _contentItemsService.loadDailyAffirmation();
    } catch (_) {
      dailyAffirmation.value = '';
    }

    await _refreshRouteAvailability();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  void openHelpNow() {
    Get.toNamed(AppRoutes.chat);
  }

  void openAction(QuickActionItem item) {
    if (item.route.trim().isEmpty) {
      return;
    }
    if (item.route == AppRoutes.chat) {
      openTalk();
      return;
    }
    if (item.route == AppRoutes.journal) {
      openJournal();
      return;
    }
    Get.toNamed(item.route, arguments: item.routeArguments);
  }

  QuickActionItem? findActionByRoute(String route) {
    for (final item in _quickActions) {
      if (item.route == route) {
        return item;
      }
    }
    return null;
  }

  QuickActionItem? findActionByTitle(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final item in _quickActions) {
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
    _routeHasContent[AppRoutes.journal] =
        await has(_contentItemsService.loadJournalPrompts);
  }

  void openTalk() {
    Get.toNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.entry(
        feature: RitualWrapFeature.talk,
        nextRoute: AppRoutes.chat,
        nextArguments: {'ritualFeature': RitualWrapFeature.talk},
      ).toMap(),
    );
  }

  Future<void> openJournal() async {
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
  }

  void openNormal() {
    Get.toNamed(AppRoutes.normal);
  }

  void openNoise() {
    Get.toNamed(AppRoutes.noise);
  }

  void openRehearse() {
    Get.toNamed(AppRoutes.rehearse);
  }

  void openSpaces() {
    Get.find<DashboardController>().switchTab(2);
  }

  void openProfile() {
    Get.find<DashboardController>().openProfile();
  }

  void openInfo() {
    Get.toNamed(AppRoutes.terms);
  }

  void openPremium() {
    Get.toNamed(AppRoutes.premium);
  }
}
