import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_assets.dart';
import '../../data/models/app_models.dart';

class ContentItemsService {
  ContentItemsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _contentItems =>
      _firestore.collection('content_items');

  CollectionReference<Map<String, dynamic>> get _mediaAssets =>
      _firestore.collection('media_assets');

  Future<List<NormalTopicItem>> loadNormalTopics() async {
    final snapshot = await _contentItems
        .where('status', isEqualTo: 'published')
        .where('type', isEqualTo: 'normal_topic')
        .get();

    final items = <_Sortable<NormalTopicItem>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
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
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: NormalTopicItem(
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
        ),
      );
    }

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items.map((item) => item.value).toList();
  }

  Future<List<JournalPrompt>> loadJournalPrompts() async {
    final snapshot = await _contentItems
        .where('status', isEqualTo: 'published')
        .where('type', isEqualTo: 'journal_prompt')
        .get();

    final items = <_Sortable<JournalPrompt>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final prompt = _firstNonEmpty([
        _string(data['title']),
        _string(data['prompt']),
        _string(data['question']),
        _string(data['body']),
      ]);
      if (prompt.isEmpty) {
        continue;
      }

      final category = _firstNonEmpty([
        _string(data['category']),
        'clarity',
      ]).toLowerCase();

      items.add(
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: JournalPrompt(
            category: category,
            prompt: prompt,
          ),
        ),
      );
    }

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items.map((item) => item.value).toList();
  }

  Future<List<KeyTermItem>> loadKeyTerms() async {
    final snapshot = await _contentItems
        .where('status', isEqualTo: 'published')
        .where('type', isEqualTo: 'key_term')
        .get();

    final items = <_Sortable<KeyTermItem>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final term = _string(data['title']);
      final definition = _firstNonEmpty([
        _string(data['body']),
        _string(data['subtitle']),
      ]);

      if (term.isEmpty || definition.isEmpty) {
        continue;
      }

      items.add(
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: KeyTermItem(
            term: term,
            definition: definition,
          ),
        ),
      );
    }

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items.map((item) => item.value).toList();
  }

  Future<List<AudioTrack>> loadAudioTracks() async {
    final snapshot = await _contentItems
        .where('status', isEqualTo: 'published')
        .where('type', isEqualTo: 'audio_track')
        .get();

    final mediaIds = <String>{};
    for (final doc in snapshot.docs) {
      mediaIds.addAll(_stringList(doc.data()['mediaIds']));
    }

    final mediaById = await _loadMediaById(mediaIds);

    final items = <_Sortable<AudioTrack>>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final itemMediaIds = _stringList(data['mediaIds']);
      final mediaId = itemMediaIds.isEmpty ? '' : itemMediaIds.first;
      final media = mediaById[mediaId];

      final pathOrUrl = _firstNonEmpty([
        media?.downloadUrl ?? '',
        _bundleAudioPathFor(media?.fileName ?? ''),
      ]);

      if (pathOrUrl.isEmpty) {
        continue;
      }

      items.add(
        _Sortable(
          sortOrder: _toInt(data['sortOrder']),
          value: AudioTrack(
            title: _firstNonEmpty([
              _string(data['title']),
              'Audio track',
            ]),
            category: _firstNonEmpty([
              _string(data['category']),
              'General',
            ]),
            description: _firstNonEmpty([
              _string(data['subtitle']),
              _string(data['body']),
            ]),
            duration: _string(data['durationLabel']),
            assetPath: pathOrUrl,
            isPremium: _toBool(data['isPremium']),
          ),
        ),
      );
    }

    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items.map((item) => item.value).toList();
  }

  Future<Map<String, _MediaItem>> _loadMediaById(Set<String> ids) async {
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
