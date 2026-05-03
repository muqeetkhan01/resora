import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/app_models.dart';

class ChatSessionService {
  ChatSessionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration sessionTimeout = Duration(minutes: 30);

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _userDoc(uid).collection('chat_sessions');

  DocumentReference<Map<String, dynamic>> _memoryProfileDoc(String uid) =>
      _userDoc(uid).collection('chat').doc('memory_profile');

  CollectionReference<Map<String, dynamic>> _messages(
    String uid,
    String sessionId,
  ) =>
      _sessions(uid).doc(sessionId).collection('messages');

  Future<String> ensureActiveSession(
    String uid, {
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final userRef = _userDoc(uid);
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data() ?? <String, dynamic>{};
    final activeSessionId =
        (userData['activeChatSessionId'] as String? ?? '').trim();
    final lastActivity = _toDateTime(userData['activeChatSessionLastActivity']);

    final hasActive = activeSessionId.isNotEmpty &&
        lastActivity != null &&
        current.difference(lastActivity) < sessionTimeout;
    if (hasActive) {
      await touchSession(uid, activeSessionId, now: current);
      return activeSessionId;
    }

    final sessionRef = _sessions(uid).doc();
    final nowMs = current.millisecondsSinceEpoch;
    await sessionRef.set(
      <String, dynamic>{
        'status': 'active',
        'startedAt': FieldValue.serverTimestamp(),
        'startedAtMs': nowMs,
        'lastActivityAt': FieldValue.serverTimestamp(),
        'lastActivityAtMs': nowMs,
      },
    );

    await userRef.set(
      <String, dynamic>{
        'activeChatSessionId': sessionRef.id,
        'activeChatSessionLastActivity': FieldValue.serverTimestamp(),
        'activeChatSessionLastActivityMs': nowMs,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (activeSessionId.isNotEmpty) {
      await closeSession(
        uid: uid,
        sessionId: activeSessionId,
        reason: 'timed_out',
        now: current,
      );
    }

    return sessionRef.id;
  }

  Future<void> touchSession(
    String uid,
    String sessionId, {
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final nowMs = current.millisecondsSinceEpoch;
    await _sessions(uid).doc(sessionId).set(
      <String, dynamic>{
        'status': 'active',
        'lastActivityAt': FieldValue.serverTimestamp(),
        'lastActivityAtMs': nowMs,
      },
      SetOptions(merge: true),
    );
    await _userDoc(uid).set(
      <String, dynamic>{
        'activeChatSessionId': sessionId,
        'activeChatSessionLastActivity': FieldValue.serverTimestamp(),
        'activeChatSessionLastActivityMs': nowMs,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> closeSession({
    required String uid,
    required String sessionId,
    required String reason,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final nowMs = current.millisecondsSinceEpoch;

    await _sessions(uid).doc(sessionId).set(
      <String, dynamic>{
        'status': 'ended',
        'endedReason': reason,
        'endedAt': FieldValue.serverTimestamp(),
        'endedAtMs': nowMs,
        'lastActivityAt': FieldValue.serverTimestamp(),
        'lastActivityAtMs': nowMs,
      },
      SetOptions(merge: true),
    );

    final userRef = _userDoc(uid);
    final snapshot = await userRef.get();
    final active =
        (snapshot.data()?['activeChatSessionId'] as String? ?? '').trim();
    if (active == sessionId) {
      await userRef.set(
        <String, dynamic>{
          'activeChatSessionId': FieldValue.delete(),
          'activeChatSessionLastActivity': FieldValue.delete(),
          'activeChatSessionLastActivityMs': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  }

  Future<void> saveMessage({
    required String uid,
    required String sessionId,
    required bool isUser,
    required String text,
    DateTime? now,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final current = now ?? DateTime.now();
    final nowMs = current.millisecondsSinceEpoch;

    await _messages(uid, sessionId).add(
      <String, dynamic>{
        'role': isUser ? 'user' : 'assistant',
        'text': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMs': nowMs,
      },
    );
  }

  Future<List<ChatMessageModel>> loadRecentMessages({
    required String uid,
    required String sessionId,
    int limit = 20,
  }) async {
    final snapshot = await _messages(uid, sessionId)
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .get();

    final rows = snapshot.docs.map((doc) => doc.data()).toList().reversed;
    return rows.map(_toChatMessage).whereType<ChatMessageModel>().toList();
  }

  Future<List<ChatMessageModel>> loadSessionTranscript({
    required String uid,
    required String sessionId,
    int limit = 120,
  }) async {
    final snapshot = await _messages(uid, sessionId)
        .orderBy('createdAtMs', descending: false)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => _toChatMessage(doc.data()))
        .whereType<ChatMessageModel>()
        .toList();
  }

  Future<Map<String, dynamic>> loadMemoryProfile(String uid) async {
    final snapshot = await _memoryProfileDoc(uid).get();
    final data = snapshot.data();
    if (data == null) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(data);
  }

  Future<void> updateMemoryProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) {
      return;
    }
    await _memoryProfileDoc(uid).set(
      <String, dynamic>{
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  ChatMessageModel? _toChatMessage(Map<String, dynamic> data) {
    final text = (data['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final role = (data['role'] as String? ?? '').trim().toLowerCase();
    final createdAt = _toDateTime(data['createdAt']) ??
        _toDateTime(data['createdAtMs']) ??
        DateTime.now();
    return ChatMessageModel(
      text: text,
      isUser: role == 'user',
      time: _formatTime(createdAt),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  static String _formatTime(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final meridiem = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $meridiem';
  }
}
