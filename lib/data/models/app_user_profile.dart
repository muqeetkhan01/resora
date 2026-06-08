import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.providerIds,
    required this.journalLockEnabled,
    required this.journalPin,
    this.isPremium = false,
    this.activePlan = 'free',
    this.hasSubscriptionHistory = false,
    this.revenueCatAppUserId,
    this.revenueCatProductIds = const <String>[],
    this.revenueCatActiveEntitlements = const <String>[],
    this.subscriptionUpdatedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String displayName;
  final String? photoUrl;
  final List<String> providerIds;
  final bool journalLockEnabled;
  final String? journalPin;
  final bool isPremium;
  final String activePlan;
  final bool hasSubscriptionHistory;
  final String? revenueCatAppUserId;
  final List<String> revenueCatProductIds;
  final List<String> revenueCatActiveEntitlements;
  final DateTime? subscriptionUpdatedAt;
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
      journalLockEnabled: data['journalLockEnabled'] == true,
      journalPin: (data['journalPin'] as String?)?.trim(),
      isPremium: data['isPremium'] == true,
      activePlan: (data['activePlan'] as String? ?? 'free').trim().isEmpty
          ? 'free'
          : (data['activePlan'] as String? ?? 'free').trim(),
      hasSubscriptionHistory: data['hasSubscriptionHistory'] == true,
      revenueCatAppUserId: (data['revenueCatAppUserId'] as String?)?.trim(),
      revenueCatProductIds:
          ((data['revenueCatProductIds'] as List<dynamic>?) ?? const [])
              .whereType<String>()
              .toList(),
      revenueCatActiveEntitlements:
          ((data['revenueCatActiveEntitlements'] as List<dynamic>?) ?? const [])
              .whereType<String>()
              .toList(),
      subscriptionUpdatedAt: _toDateTime(data['subscriptionUpdatedAt']),
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
