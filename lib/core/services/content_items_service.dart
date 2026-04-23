import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/app_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../constants/app_assets.dart';
import '../constants/app_icons.dart';

class ContentItemsService {
  ContentItemsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _contentItems =>
      _firestore.collection('content_items');

  CollectionReference<Map<String, dynamic>> get _mediaAssets =>
      _firestore.collection('media_assets');

  CollectionReference<Map<String, dynamic>> get _premiumPlans =>
      _firestore.collection('premium_plans');

  Future<List<OnboardingItem>> loadOnboardingItems() async {
    final rows = await _loadPublishedContentByType('onboarding');

    final items = <OnboardingItem>[];
    for (var index = 0; index < rows.length; index += 1) {
      final data = rows[index];
      final title = _string(data['title']);
      final subtitle = _firstNonEmpty([
        _string(data['subtitle']),
        _string(data['body']),
      ]);
      if (title.isEmpty || subtitle.isEmpty) {
        continue;
      }

      final caption = _firstNonEmpty([
        _string(data['caption']),
        _string(data['category']),
        'ground',
      ]);

      items.add(
        OnboardingItem(
          title: title,
          subtitle: subtitle,
          caption: caption,
          icon: _iconForOnboarding(caption, index),
          accentColor: _accentColorFor(caption, index),
        ),
      );
    }

    return items;
  }

  Future<List<QuickActionItem>> loadQuickActions() async {
    final rows = await _loadPublishedContentByType(
      'quick_action',
      aliases: const ['quick_actions'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <QuickActionItem>[];
    for (final data in rows) {
      final title = _string(data['title']);
      if (title.isEmpty) {
        continue;
      }

      final route = _resolveRouteTarget(
        _string(data['routeTarget']),
        fallbackTitle: title,
      );

      final image = _resolveImageFor(
        mediaById: mediaById,
        mediaIds: _stringList(data['mediaIds']),
        route: route,
      );

      items.add(
        QuickActionItem(
          title: title,
          subtitle: _firstNonEmpty([
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          icon: _iconForRoute(route),
          accentColor: _accentColorFor(_string(data['category']), items.length),
          route: route,
          imagePath: image.isEmpty ? null : image,
          premium: _toBool(data['isPremium']),
        ),
      );
    }

    return items;
  }

  Future<List<QuickActionItem>> loadSpaces() async {
    final rows = await _loadPublishedContentByType(
      'space',
      aliases: const ['spaces'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <QuickActionItem>[];
    for (final data in rows) {
      final title = _string(data['title']);
      if (title.isEmpty) {
        continue;
      }

      final route = _resolveRouteTarget(
        _string(data['routeTarget']),
        fallbackTitle: title,
      );

      final image = _resolveImageFor(
        mediaById: mediaById,
        mediaIds: _stringList(data['mediaIds']),
        route: route,
      );

      items.add(
        QuickActionItem(
          title: title,
          subtitle: _firstNonEmpty([
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          icon: _iconForRoute(route),
          accentColor: _accentColorFor(_string(data['category']), items.length),
          route: route,
          imagePath: image.isEmpty ? null : image,
          premium: _toBool(data['isPremium']),
        ),
      );
    }

    return items;
  }

  Future<List<JournalPrompt>> loadJournalPrompts() async {
    final rows = await _loadPublishedContentByType(
      'journal_prompt',
      aliases: const ['journal_prompts', 'journal'],
    );

    final items = <JournalPrompt>[];
    for (final data in rows) {
      final prompt = _firstNonEmpty([
        _string(data['title']),
        _string(data['prompt']),
        _string(data['question']),
        _string(data['body']),
      ]);
      if (prompt.isEmpty) {
        continue;
      }

      items.add(
        JournalPrompt(
          category: _firstNonEmpty([
            _string(data['category']),
            'clarity',
          ]).toLowerCase(),
          prompt: prompt,
        ),
      );
    }

    return items;
  }

  Future<List<ResetOption>> loadResetOptions() async {
    final rows = await _loadPublishedContentByType(
      'reset',
      aliases: const ['resets', 'gentle_reset'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <ResetOption>[];
    for (final data in rows) {
      final title = _string(data['title']);
      if (title.isEmpty) {
        continue;
      }

      final mediaIds = _stringList(data['mediaIds']);
      final media = mediaIds.isEmpty ? null : mediaById[mediaIds.first];
      final audioPath = _firstNonEmpty([
        media?.downloadUrl ?? '',
        _bundleAudioPathFor(media?.fileName ?? ''),
      ]);

      items.add(
        ResetOption(
          category: _firstNonEmpty([
            _string(data['category']),
            'ground',
          ]).toLowerCase(),
          title: title,
          subtitle: _firstNonEmpty([
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          duration: _firstNonEmpty([
            _string(data['durationLabel']),
            '2 min',
          ]),
          icon: AppIcons.resets,
          audioPath: audioPath,
        ),
      );
    }

    return items;
  }

  Future<List<MindfulnessSession>> loadMindfulnessSessions() async {
    final rows = await _loadPublishedContentByType(
      'mindfulness_session',
      aliases: const ['mindfulness', 'session'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <MindfulnessSession>[];
    for (final data in rows) {
      final title = _string(data['title']);
      if (title.isEmpty) {
        continue;
      }

      final category = _firstNonEmpty([
        _string(data['category']),
        'Guided',
      ]);
      final mediaIds = _stringList(data['mediaIds']);
      final media = mediaIds.isEmpty ? null : mediaById[mediaIds.first];
      final audioPath = _firstNonEmpty([
        media?.downloadUrl ?? '',
        _bundleAudioPathFor(media?.fileName ?? ''),
      ]);

      items.add(
        MindfulnessSession(
          title: title,
          subtitle: _firstNonEmpty([
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          length: _firstNonEmpty([
            _string(data['durationLabel']),
            '5 min',
          ]),
          type: category,
          color: _colorForSessionCategory(category),
          isPremium: _toBool(data['isPremium']),
          audioPath: audioPath,
        ),
      );
    }

    return items;
  }

  Future<List<AudioTrack>> loadAudioTracks() async {
    final rows = await _loadPublishedContentByType(
      'audio_track',
      aliases: const ['audio', 'track'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <AudioTrack>[];
    for (final data in rows) {
      final title = _firstNonEmpty([
        _string(data['title']),
        'Audio track',
      ]);

      final mediaIds = _stringList(data['mediaIds']);
      final media = mediaIds.isEmpty ? null : mediaById[mediaIds.first];
      final pathOrUrl = _firstNonEmpty([
        media?.downloadUrl ?? '',
        _bundleAudioPathFor(media?.fileName ?? ''),
      ]);

      if (title.isEmpty || pathOrUrl.isEmpty) {
        continue;
      }

      items.add(
        AudioTrack(
          title: title,
          category: _firstNonEmpty([
            _string(data['category']),
            'General',
          ]),
          description: _firstNonEmpty([
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          duration: _firstNonEmpty([
            _string(data['durationLabel']),
            '1 min',
          ]),
          assetPath: pathOrUrl,
          isPremium: _toBool(data['isPremium']),
        ),
      );
    }

    return items;
  }

  Future<List<RehearsalScenario>> loadRehearsalScenarios() async {
    final rows = await _loadPublishedContentByType(
      'rehearsal_scenario',
      aliases: const ['rehearsal', 'rehearse'],
    );
    final mediaById = await _loadMediaById(_collectMediaIds(rows));

    final items = <RehearsalScenario>[];
    for (final data in rows) {
      final title = _string(data['title']);
      if (title.isEmpty) {
        continue;
      }

      final mediaIds = _stringList(data['mediaIds']);
      final media = mediaIds.isEmpty ? null : mediaById[mediaIds.first];
      final audioPath = _firstNonEmpty([
        media?.downloadUrl ?? '',
        _bundleAudioPathFor(media?.fileName ?? ''),
      ]);

      items.add(
        RehearsalScenario(
          title: title,
          category: _firstNonEmpty([
            _string(data['category']),
            'connect',
          ]).toLowerCase(),
          reframe: _firstNonEmpty([
            _string(data['reframe']),
            _string(data['subtitle']),
            _string(data['body']),
          ]),
          script: _firstNonEmpty([
            _string(data['script']),
            _string(data['body']),
          ]),
          steps: _stringList(data['bulletPoints']),
          isPremium: _toBool(data['isPremium']),
          audioPath: audioPath,
        ),
      );
    }

    return items;
  }

  Future<List<NormalTopicItem>> loadNormalTopics() async {
    final rows = await _loadPublishedContentByType(
      'normal_topic',
      aliases: const ['normal_topics', 'normal'],
    );

    return _mapNormalTopics(rows);
  }

  Stream<List<NormalTopicItem>> watchNormalTopics() {
    final allowedTypes = <String>{
      _normalizeToken('normal_topic'),
      _normalizeToken('normal_topics'),
      _normalizeToken('normal'),
    };

    return _contentItems.snapshots().map((snapshot) {
      final sortable = <_Sortable<Map<String, dynamic>>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rowType = _normalizeToken(data['type']);
        if (!allowedTypes.contains(rowType)) {
          continue;
        }

        if (!_isPublished(data)) {
          continue;
        }

        sortable.add(
          _Sortable(
            sortOrder: _toInt(data['sortOrder']),
            value: data,
          ),
        );
      }

      sortable.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final rows = sortable.map((item) => item.value).toList();
      return _mapNormalTopics(rows);
    });
  }

  List<NormalTopicItem> _mapNormalTopics(List<Map<String, dynamic>> rows) {
    final items = <NormalTopicItem>[];
    for (final data in rows) {
      final question = _firstNonEmpty([
        _string(data['question']),
        _string(data['title']),
      ]);
      final answer = _firstNonEmpty([
        _string(data['answer']),
        _string(data['body']),
      ]);

      if (question.isEmpty || answer.isEmpty) {
        continue;
      }

      items.add(
        NormalTopicItem(
          tab: _firstNonEmpty([
            _string(data['category']),
            'general',
          ]),
          question: question,
          expertAnswer: answer,
          metoo: _toInt(data['metooCount']),
          voices: _stringList(data['voices']),
          expertByline: _firstNonEmpty([
            _string(data['expertByline']),
            'LBS',
          ]),
        ),
      );
    }

    return items;
  }

  Future<List<KeyTermItem>> loadKeyTerms() async {
    final rows = await _loadPublishedContentByType(
      'key_term',
      aliases: const ['key_terms', 'term'],
    );

    final items = <KeyTermItem>[];
    for (final data in rows) {
      final term = _string(data['title']);
      final definition = _firstNonEmpty([
        _string(data['body']),
        _string(data['subtitle']),
      ]);

      if (term.isEmpty || definition.isEmpty) {
        continue;
      }

      items.add(
        KeyTermItem(
          term: term,
          definition: definition,
        ),
      );
    }

    return items;
  }

  Future<List<QaItem>> loadQaItems() async {
    final rows = await _loadPublishedContentByType('qa');

    final items = <QaItem>[];
    for (final data in rows) {
      final question = _firstNonEmpty([
        _string(data['question']),
        _string(data['title']),
      ]);
      final answer = _firstNonEmpty([
        _string(data['answer']),
        _string(data['body']),
      ]);
      if (question.isEmpty || answer.isEmpty) {
        continue;
      }

      items.add(
        QaItem(
          question: question,
          answer: answer,
          category: _firstNonEmpty([
            _string(data['category']),
            'General',
          ]),
          isPremium: _toBool(data['isPremium']),
        ),
      );
    }

    return items;
  }

  Future<List<CommunityPost>> loadCommunityPosts() async {
    final rows = await _loadPublishedContentByType(
      'community_post',
      aliases: const ['community', 'community_posts'],
    );

    final items = <CommunityPost>[];
    for (final data in rows) {
      final author = _firstNonEmpty([
        _string(data['authorName']),
        'Member',
      ]);
      final title = _firstNonEmpty([
        _string(data['title']),
        _string(data['question']),
      ]);
      final preview = _firstNonEmpty([
        _string(data['subtitle']),
        _string(data['body']),
      ]);

      if (title.isEmpty || preview.isEmpty) {
        continue;
      }

      items.add(
        CommunityPost(
          author: author,
          role: _firstNonEmpty([
            _string(data['authorRole']),
            'Community',
          ]),
          title: title,
          preview: preview,
          category: _firstNonEmpty([
            _string(data['category']),
            'General',
          ]),
          likes: _toInt(data['likes']),
          comments: _toInt(data['comments']),
        ),
      );
    }

    return items;
  }

  Future<List<AffirmationItem>> loadAffirmations() async {
    final rows = await _loadPublishedContentByType(
      'affirmation',
      aliases: const ['affirmations'],
    );

    final items = <AffirmationItem>[];
    for (final data in rows) {
      final text = _firstNonEmpty([
        _string(data['title']),
        _string(data['body']),
      ]);
      if (text.isEmpty) {
        continue;
      }

      items.add(
        AffirmationItem(
          category: _firstNonEmpty([
            _string(data['category']),
            'Daily',
          ]),
          text: text,
          duration: _firstNonEmpty([
            _string(data['durationLabel']),
            '30 sec',
          ]),
          isPremium: _toBool(data['isPremium']),
          isSaved: false,
        ),
      );
    }

    return items;
  }

  Future<List<PremiumPlan>> loadPremiumPlans() async {
    final snapshot = await _premiumPlans.get();

    final sortable = <_Sortable<PremiumPlan>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (!_toBool(data['isActive'])) {
        continue;
      }

      final title = _firstNonEmpty([
        _string(data['name']),
        _string(data['title']),
      ]);
      final price = _firstNonEmpty([
        _string(data['priceLabel']),
        _string(data['price']),
      ]);
      if (title.isEmpty || price.isEmpty) {
        continue;
      }

      sortable.add(
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: PremiumPlan(
            title: title,
            price: price,
            caption: _firstNonEmpty([
              _string(data['headline']),
              _string(data['description']),
              _string(data['billingPeriod']),
            ]),
            highlight: _toBool(data['isHighlighted']),
          ),
        ),
      );
    }

    sortable.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sortable.map((item) => item.value).toList();
  }

  Future<String> loadDailyAffirmation() async {
    final affirmations = await loadAffirmations();
    if (affirmations.isEmpty) {
      return '';
    }
    return affirmations.first.text;
  }

  Future<List<Map<String, dynamic>>> _loadPublishedContentByType(
    String type, {
    List<String> aliases = const [],
  }) async {
    final snapshot = await _contentItems.get();
    final allowedTypes = <String>{
      _normalizeToken(type),
      ...aliases.map(_normalizeToken),
    };
    final sortable = <_Sortable<Map<String, dynamic>>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rowType = _normalizeToken(data['type']);
      if (!allowedTypes.contains(rowType)) {
        continue;
      }

      if (!_isPublished(data)) {
        continue;
      }

      sortable.add(
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: data,
        ),
      );
    }

    sortable.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sortable.map((item) => item.value).toList();
  }

  static bool _isPublished(Map<String, dynamic> data) {
    final status = _normalizeToken(data['status']);
    if (status.isEmpty) {
      final legacy = data['isPublished'];
      if (legacy is bool) {
        return legacy;
      }
      // Legacy records may not have status at all; keep them visible.
      return true;
    }

    return status == 'published' || status == 'live' || status == 'active';
  }

  static String _normalizeToken(dynamic value) {
    final raw = _string(value);
    if (raw.isEmpty) {
      return '';
    }

    final snakeCase =
        raw.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (match) {
      return '${match.group(1)}_${match.group(2)}';
    });

    return snakeCase
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
  }

  Future<Map<String, _MediaItem>> _loadMediaById(Set<String> ids) async {
    if (ids.isEmpty) {
      return const {};
    }

    final map = <String, _MediaItem>{};
    for (final id in ids) {
      final snapshot = await _mediaAssets.doc(id).get();
      final data = snapshot.data();
      if (data == null) {
        continue;
      }

      map[id] = _MediaItem(
        downloadUrl: _string(data['downloadUrl']),
        fileName: _string(data['fileName']),
      );
    }

    return map;
  }

  Set<String> _collectMediaIds(List<Map<String, dynamic>> rows) {
    final ids = <String>{};
    for (final data in rows) {
      ids.addAll(_stringList(data['mediaIds']));
    }
    return ids;
  }

  String _resolveImageFor({
    required Map<String, _MediaItem> mediaById,
    required List<String> mediaIds,
    required String route,
  }) {
    final media = mediaIds.isEmpty ? null : mediaById[mediaIds.first];
    return _firstNonEmpty([
      media?.downloadUrl ?? '',
      _bundleImagePathFor(media?.fileName ?? ''),
      _defaultImageForRoute(route),
    ]);
  }

  static String _resolveRouteTarget(
    String routeTarget, {
    required String fallbackTitle,
  }) {
    final raw = routeTarget.trim();
    if (raw.isNotEmpty) {
      if (raw.startsWith('/')) {
        return raw;
      }

      switch (raw.toLowerCase()) {
        case 'chat':
        case 'talk':
        case 'talk_to_resora':
          return AppRoutes.chat;
        case 'normal':
        case 'is_this_normal':
          return AppRoutes.normal;
        case 'resets':
        case 'gentle_reset':
          return AppRoutes.resets;
        case 'noise':
        case 'quiet_the_noise':
          return AppRoutes.noise;
        case 'rehearse':
        case 'rehearse_the_moment':
          return AppRoutes.rehearse;
        case 'journal':
          return AppRoutes.journal;
        case 'terms':
        case 'key_terms':
          return AppRoutes.terms;
        case 'spaces':
        case 'space':
          return AppRoutes.spaces;
      }
    }

    final title = fallbackTitle.toLowerCase();
    if (title.contains('talk')) {
      return AppRoutes.chat;
    }
    if (title.contains('normal')) {
      return AppRoutes.normal;
    }
    if (title.contains('reset')) {
      return AppRoutes.resets;
    }
    if (title.contains('noise')) {
      return AppRoutes.noise;
    }
    if (title.contains('rehearse')) {
      return AppRoutes.rehearse;
    }
    if (title.contains('journal')) {
      return AppRoutes.journal;
    }
    if (title.contains('term')) {
      return AppRoutes.terms;
    }

    return AppRoutes.spaces;
  }

  static IconData _iconForRoute(String route) {
    switch (route) {
      case AppRoutes.chat:
        return AppIcons.aiChat;
      case AppRoutes.normal:
        return AppIcons.isNormal;
      case AppRoutes.resets:
        return AppIcons.resets;
      case AppRoutes.noise:
        return AppIcons.noise;
      case AppRoutes.rehearse:
        return AppIcons.rehearse;
      case AppRoutes.journal:
        return AppIcons.journal;
      case AppRoutes.terms:
        return AppIcons.terms;
      default:
        return AppIcons.spacesFilled;
    }
  }

  static IconData _iconForOnboarding(String caption, int index) {
    final value = caption.toLowerCase();
    if (value.contains('ground') || value.contains('calm')) {
      return AppIcons.resets;
    }
    if (value.contains('journal') || value.contains('reflect')) {
      return AppIcons.journal;
    }
    if (value.contains('restore') || value.contains('talk')) {
      return AppIcons.aiGuidance;
    }
    if (index % 3 == 1) {
      return AppIcons.resets;
    }
    if (index % 3 == 2) {
      return AppIcons.journal;
    }
    return AppIcons.aiGuidance;
  }

  static Color _accentColorFor(String value, int index) {
    final tag = value.trim().toLowerCase();
    if (tag == 'ground') {
      return AppColors.sage;
    }
    if (tag == 'clarity') {
      return AppColors.warmIvory;
    }
    if (tag == 'restore') {
      return AppColors.softBlueGrey;
    }
    if (tag == 'release') {
      return AppColors.dustyRose;
    }
    if (tag == 'connect') {
      return AppColors.blush;
    }

    switch (index % 3) {
      case 1:
        return AppColors.warmIvory;
      case 2:
        return AppColors.softBlueGrey;
      default:
        return AppColors.sage;
    }
  }

  static Color _colorForSessionCategory(String category) {
    final value = category.trim().toLowerCase();
    if (value.contains('nature')) {
      return AppColors.softBlueGrey;
    }
    if (value.contains('visual')) {
      return AppColors.warmIvory;
    }
    if (value.contains('guided')) {
      return AppColors.sage;
    }
    return AppColors.categoryColor(value);
  }

  static String _defaultImageForRoute(String route) {
    switch (route) {
      case AppRoutes.chat:
        return AppAssets.homeTalkOcean;
      case AppRoutes.normal:
        return AppAssets.homeNormalStem;
      case AppRoutes.journal:
        return AppAssets.homeJournalBed;
      case AppRoutes.noise:
        return AppAssets.spaceRoom;
      case AppRoutes.resets:
        return AppAssets.spaceGarden;
      case AppRoutes.rehearse:
        return AppAssets.spaceMountain;
      case AppRoutes.terms:
        return AppAssets.homeComingSoonFlower;
      default:
        return '';
    }
  }

  static String _bundleImagePathFor(String fileName) {
    switch (fileName.trim().toLowerCase()) {
      case 'home_talk_ocean.jpeg':
        return AppAssets.homeTalkOcean;
      case 'home_normal_stem.jpeg':
        return AppAssets.homeNormalStem;
      case 'home_journal_bed.jpeg':
        return AppAssets.homeJournalBed;
      case 'home_coming_soon_flower.jpeg':
        return AppAssets.homeComingSoonFlower;
      case 'space_room.jpeg':
        return AppAssets.spaceRoom;
      case 'space_garden.jpeg':
        return AppAssets.spaceGarden;
      case 'space_mountain.jpeg':
        return AppAssets.spaceMountain;
      case 'journal_bed.png':
        return AppAssets.journalBed;
      case 'archway.png':
        return AppAssets.archway;
      case 'curtain_light.jpeg':
        return AppAssets.curtainLight;
      default:
        return '';
    }
  }

  static String _bundleAudioPathFor(String fileName) {
    switch (fileName.trim().toLowerCase()) {
      case 'ambient_soft_rain.mp3':
        return AppAssets.ambientSoftRain;
      case 'ambient_brown_noise.mp3':
        return AppAssets.ambientBrownNoise;
      case 'guided_exhale.mp3':
        return AppAssets.guidedExhale;
      case 'guided_parenting_calm.mp3':
        return AppAssets.guidedParentingCalm;
      case 'reset_breath_reset.mp3':
        return AppAssets.resetBreathReset;
      case 'reset_step_away.mp3':
        return AppAssets.resetStepAway;
      case 'reset_ground_54321.mp3':
        return AppAssets.resetGroundFiveFourThreeTwoOne;
      case 'reset_box_breath.mp3':
        return AppAssets.resetBoxBreath;
      case 'reset_cold_water.mp3':
        return AppAssets.resetColdWater;
      case 'rehearse_partner_after_hard_night.mp3':
        return AppAssets.rehearsePartnerAfterHardNight;
      case 'rehearse_setting_limit.mp3':
        return AppAssets.rehearseSettingLimit;
      case 'rehearse_ask_for_need.mp3':
        return AppAssets.rehearseAskForNeed;
      case 'rehearse_repair_after_temper.mp3':
        return AppAssets.rehearseRepairAfterTemper;
      case 'rehearse_hard_conversation_work.mp3':
        return AppAssets.rehearseHardConversationWork;
      default:
        return '';
    }
  }

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.trim().toLowerCase() == 'true';
    }
    return false;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static String _string(dynamic value) {
    return (value as String? ?? '').trim();
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    return value.whereType<String>().map((item) => item.trim()).toList();
  }
}

class _MediaItem {
  const _MediaItem({
    required this.downloadUrl,
    required this.fileName,
  });

  final String downloadUrl;
  final String fileName;
}

class _Sortable<T> {
  const _Sortable({
    required this.sortOrder,
    required this.value,
  });

  final int sortOrder;
  final T value;
}
