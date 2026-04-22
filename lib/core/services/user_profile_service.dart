import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/app_user_profile.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<AppUserProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return AppUserProfile.fromDocument(snapshot);
    });
  }

  Future<AppUserProfile> ensureProfileForUser(
    User user, {
    String? preferredDisplayName,
  }) async {
    final document = _users.doc(user.uid);
    final snapshot = await document.get();
    final currentProfile =
        snapshot.exists ? AppUserProfile.fromDocument(snapshot) : null;

    final resolvedName = _firstNonEmpty([
      preferredDisplayName,
      currentProfile?.displayName,
      user.displayName,
    ]);

    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': resolvedName,
      'photoUrl': user.photoURL,
      'providerIds': user.providerData
          .map((provider) => provider.providerId)
          .where((providerId) => providerId.trim().isNotEmpty)
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await document.set(data, SetOptions(merge: true));

    final refreshed = await document.get();
    return AppUserProfile.fromDocument(refreshed);
  }

  Future<void> updateProfile({
    required User user,
    required String displayName,
    required String? email,
  }) {
    return _users.doc(user.uid).set(
      <String, dynamic>{
        'uid': user.uid,
        'email': email,
        'displayName': displayName.trim(),
        'photoUrl': user.photoURL,
        'providerIds': user.providerData
            .map((provider) => provider.providerId)
            .where((providerId) => providerId.trim().isNotEmpty)
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateJournalLock({
    required String uid,
    required bool enabled,
    required String? pin,
  }) {
    final trimmedPin = pin?.trim();

    return _users.doc(uid).set(
      <String, dynamic>{
        'journalLockEnabled': enabled,
        'journalPin':
            enabled && (trimmedPin?.isNotEmpty ?? false) ? trimmedPin : null,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }
}
