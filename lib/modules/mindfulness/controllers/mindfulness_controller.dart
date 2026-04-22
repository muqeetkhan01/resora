import 'package:get/get.dart';

import '../../../core/services/content_items_service.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';

class MindfulnessController extends GetxController {
  MindfulnessController({ContentItemsService? contentItemsService})
      : _contentItemsService = contentItemsService ?? ContentItemsService();

  final ContentItemsService _contentItemsService;

  final selectedTab = 0.obs;
  final _sessions = <MindfulnessSession>[].obs;

  List<String> get tabs {
    final values = <String>[];
    for (final session in _sessions) {
      final type = session.type.trim();
      if (type.isEmpty || values.contains(type)) {
        continue;
      }
      values.add(type);
    }
    return values;
  }

  List<MindfulnessSession> get sessions {
    final availableTabs = tabs;
    if (availableTabs.isEmpty) {
      return const <MindfulnessSession>[];
    }
    final safeIndex = selectedTab.value.clamp(0, availableTabs.length - 1);
    final currentType = availableTabs[safeIndex];

    return _sessions
        .where((session) => session.type == currentType)
        .toList();
  }

  MindfulnessSession? get featuredSession {
    if (_sessions.isEmpty) {
      return null;
    }
    return _sessions.first;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _contentItemsService.loadMindfulnessSessions();
      _sessions.assignAll(sessions);
    } catch (_) {
      _sessions.clear();
    }

    final availableTabs = tabs;
    if (availableTabs.isEmpty) {
      selectedTab.value = 0;
      return;
    }

    final initialTab = Get.arguments;
    if (initialTab is int &&
        initialTab >= 0 &&
        initialTab < availableTabs.length) {
      selectedTab.value = initialTab;
      return;
    }

    selectedTab.value = selectedTab.value.clamp(0, availableTabs.length - 1);
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) {
      return;
    }
    selectedTab.value = index;
  }

  void openSession(MindfulnessSession session) {
    if (session.isPremium) {
      Get.toNamed(AppRoutes.premium);
      return;
    }

    Get.toNamed(AppRoutes.mindfulnessDetail, arguments: session);
  }

  void playSession(MindfulnessSession session) {
    final track = AudioTrack(
      title: session.title,
      category: session.type,
      description: session.subtitle,
      duration: session.length,
      assetPath: session.audioPath,
      isPremium: session.isPremium,
    );
    Get.toNamed(AppRoutes.audioPlayer, arguments: track);
  }
}
