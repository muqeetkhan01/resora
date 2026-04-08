import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.providerIds,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String? photoUrl;
  final List<String> providerIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasDisplayName => displayName.trim().isNotEmpty;

  String get fallbackName {
    if (hasDisplayName) {
      return displayName.trim();
    }

    final emailValue = email?.trim();
    if (emailValue != null &&
        emailValue.isNotEmpty &&
        emailValue.contains('@')) {
      return emailValue.split('@').first;
    }

    return 'there';
  }

  factory AppUserProfile.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return AppUserProfile(
      uid: document.id,
      email: data['email'] as String?,
      displayName: (data['displayName'] as String? ?? '').trim(),
      photoUrl: data['photoUrl'] as String?,
      providerIds: ((data['providerIds'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
