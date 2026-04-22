import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/app_models.dart';

class UserGeneratedContentService {
  UserGeneratedContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _journalEntries(String uid) =>
      _userDoc(uid).collection('journal_entries');

  CollectionReference<Map<String, dynamic>> _normalQuestions(String uid) =>
      _userDoc(uid).collection('normal_questions');

  CollectionReference<Map<String, dynamic>> _normalVoices(String uid) =>
      _userDoc(uid).collection('normal_voices');

  Future<void> saveJournalEntry({
    required String uid,
    required String prompt,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return;
    }

    await _journalEntries(uid).add(
      <String, dynamic>{
        'prompt': prompt.trim(),
        'body': trimmedBody,
        'wordCount': _wordCount(trimmedBody),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> submitNormalQuestion({
    required String uid,
    required String question,
    required String category,
  }) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      return;
    }

    await _normalQuestions(uid).add(
      <String, dynamic>{
        'question': trimmedQuestion,
        'category': category.trim().isEmpty ? 'community' : category.trim(),
        'expertAnswer':
            'Thank you for sharing this. Our team will respond with a grounded answer soon.',
        'expertByline': 'Resora',
        'metooCount': 1,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> submitNormalVoice({
    required String uid,
    required String topicQuestion,
    required String voice,
  }) async {
    final trimmedVoice = voice.trim();
    final trimmedTopic = topicQuestion.trim();
    if (trimmedVoice.isEmpty || trimmedTopic.isEmpty) {
      return;
    }

    await _normalVoices(uid).add(
      <String, dynamic>{
        'topicQuestion': trimmedTopic,
        'topicKey': _topicKey(trimmedTopic),
        'voice': trimmedVoice,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<List<NormalTopicItem>> loadNormalQuestions(String uid) async {
    final snapshot = await _normalQuestions(uid)
        .orderBy('createdAt', descending: true)
        .limit(80)
        .get();

    final items = <NormalTopicItem>[];
    for (final document in snapshot.docs) {
      final data = document.data();
      final question = _string(data['question']);
      if (question.isEmpty) {
        continue;
      }

      items.add(
        NormalTopicItem(
          tab: _firstNonEmpty([
            _string(data['category']),
            'community',
          ]),
          question: question,
          expertAnswer: _firstNonEmpty([
            _string(data['expertAnswer']),
            'Thank you for sharing this. Our team will respond with a grounded answer soon.',
          ]),
          metoo: _toInt(data['metooCount']),
          voices: const [],
          expertByline: _firstNonEmpty([
            _string(data['expertByline']),
            'Resora',
          ]),
        ),
      );
    }

    return items;
  }

  Future<Map<String, List<String>>> loadNormalVoicesByTopic(String uid) async {
    final snapshot = await _normalVoices(uid)
        .orderBy('createdAt', descending: false)
        .limit(400)
        .get();

    final grouped = <String, List<String>>{};
    for (final document in snapshot.docs) {
      final data = document.data();
      final voice = _string(data['voice']);
      if (voice.isEmpty) {
        continue;
      }

      final key = _firstNonEmpty([
        _string(data['topicKey']),
        _topicKey(_string(data['topicQuestion'])),
      ]);
      if (key.isEmpty) {
        continue;
      }

      final values = grouped[key] ?? <String>[];
      values.add(voice);
      grouped[key] = values;
    }

    return grouped;
  }

  static int _wordCount(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return 0;
    }
    return text.split(RegExp(r'\s+')).length;
  }

  static String _topicKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _string(dynamic value) {
    if (value is String) {
      return value.trim();
    }
    return '';
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

  static String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }
}
