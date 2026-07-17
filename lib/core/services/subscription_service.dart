import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/models/app_user_profile.dart';
import '../constants/subscription_constants.dart';
import '../controllers/app_session_controller.dart';
import 'user_profile_service.dart';

class SubscriptionService extends GetxService {
  SubscriptionService({
    FirebaseAuth? auth,
    UserProfileService? profileService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _profileService = profileService ?? UserProfileService();

  final FirebaseAuth _auth;
  final UserProfileService _profileService;

  final isConfigured = false.obs;
  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final isRestoring = false.obs;
  final isPremium = false.obs;
  final hasSubscriptionHistory = false.obs;
  final activePlan = 'free'.obs;
  final packages = <Package>[].obs;
  final customerInfo = Rxn<CustomerInfo>();

  StreamSubscription<User?>? _authSubscription;
  CustomerInfoUpdateListener? _customerInfoListener;

  bool get canShowRestore =>
      isPremium.value ||
      hasSubscriptionHistory.value ||
      (Get.isRegistered<AppSessionController>() &&
          (Get.find<AppSessionController>().profile?.hasSubscriptionHistory ==
              true));

  bool get hasAvailablePackages => packages.isNotEmpty;

  Future<void> init() async {
    if (isLoading.value || isConfigured.value) {
      return;
    }

    final apiKey = _apiKeyForPlatform;
    if (apiKey.isEmpty) {
      debugPrint(
        'RevenueCat is not configured. Pass REVENUECAT_IOS_API_KEY with --dart-define.',
      );
      _syncFromProfile(Get.isRegistered<AppSessionController>()
          ? Get.find<AppSessionController>().profile
          : null);
      return;
    }

    isLoading.value = true;
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = _auth.currentUser?.uid;
      await Purchases.configure(configuration);
      isConfigured.value = true;

      _customerInfoListener = _handleCustomerInfo;
      Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);

      _authSubscription =
          _auth.authStateChanges().skip(1).listen(_handleAuthChanged);
      await refresh();
    } catch (error) {
      debugPrint('RevenueCat configure failed: $error');
      _syncFromProfile(Get.isRegistered<AppSessionController>()
          ? Get.find<AppSessionController>().profile
          : null);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    if (!isConfigured.value) {
      _syncFromProfile(Get.isRegistered<AppSessionController>()
          ? Get.find<AppSessionController>().profile
          : null);
      return;
    }

    isLoading.value = true;
    try {
      final info = await Purchases.getCustomerInfo();
      await _handleCustomerInfo(info);
      await loadOfferings();
    } catch (error) {
      debugPrint('RevenueCat refresh failed: $error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOfferings() async {
    if (!isConfigured.value) {
      return;
    }

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current ??
          offerings.all[SubscriptionConstants.currentOfferingId];
      packages.assignAll(offering?.availablePackages ?? const []);
    } catch (error) {
      debugPrint(
        'RevenueCat offerings failed for offering '
        '"${SubscriptionConstants.currentOfferingId}" with products '
        '${SubscriptionConstants.productIdsByPlan.values.join(', ')}: $error',
      );
      packages.clear();
      if (kDebugMode) {
        await _logStoreProductDiagnostics();
      }
    }
  }

  Future<void> _logStoreProductDiagnostics() async {
    final requestedIds = SubscriptionConstants.productIdsByPlan.values.toList();
    try {
      final products = await Purchases.getProducts(requestedIds);
      final returnedIds = products.map((product) => product.identifier).toSet();
      final missingIds = requestedIds.where((id) => !returnedIds.contains(id));
      debugPrint(
        'Direct StoreKit lookup returned: '
        '${returnedIds.isEmpty ? '(none)' : returnedIds.join(', ')}. '
        'Missing: ${missingIds.join(', ')}.',
      );
    } catch (error) {
      debugPrint('Direct StoreKit product lookup failed: $error');
    }
  }

  Package? packageForPlan(String planId) {
    final productId = SubscriptionConstants.productIdsByPlan[planId];
    if (productId == null) {
      return null;
    }

    for (final package in packages) {
      if (package.storeProduct.identifier == productId) {
        return package;
      }
    }

    final expectedType = switch (planId) {
      'monthly' => PackageType.monthly,
      'yearly' => PackageType.annual,
      'lifetime' => PackageType.lifetime,
      _ => PackageType.unknown,
    };

    for (final package in packages) {
      if (package.packageType == expectedType) {
        return package;
      }
    }

    return null;
  }

  String? priceForPlan(String planId) =>
      packageForPlan(planId)?.storeProduct.priceString;

  Future<bool> purchasePlan(String planId) async {
    if (!isConfigured.value) {
      throw const SubscriptionException(
        'Subscriptions are not configured for this build yet.',
      );
    }

    if (packages.isEmpty) {
      await loadOfferings();
    }

    final package = packageForPlan(planId);
    if (package == null) {
      throw SubscriptionException(
        'The $planId plan is not available from RevenueCat yet.',
      );
    }

    isPurchasing.value = true;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      await _handleCustomerInfo(result.customerInfo);
      return isPremium.value;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      throw SubscriptionException(error.message ?? 'Purchase failed.');
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!isConfigured.value) {
      throw const SubscriptionException(
        'Subscriptions are not configured for this build yet.',
      );
    }

    isRestoring.value = true;
    try {
      final info = await Purchases.restorePurchases();
      await _handleCustomerInfo(info);
      return isPremium.value;
    } on PlatformException catch (error) {
      throw SubscriptionException(error.message ?? 'Restore failed.');
    } finally {
      isRestoring.value = false;
    }
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (!isConfigured.value) {
      return;
    }

    try {
      if (user == null) {
        final info = await Purchases.logOut();
        await _handleCustomerInfo(info);
        return;
      }

      final result = await Purchases.logIn(user.uid);
      await _handleCustomerInfo(result.customerInfo);
      await loadOfferings();
    } catch (error) {
      debugPrint('RevenueCat auth sync failed: $error');
    }
  }

  Future<void> _handleCustomerInfo(CustomerInfo info) async {
    customerInfo.value = info;

    final activeEntitlements = info.entitlements.active.keys.toList();
    final purchasedIds = info.allPurchasedProductIdentifiers;
    final activeProductIds = info.activeSubscriptions.toSet();
    final knownProductIds =
        SubscriptionConstants.productIdsByPlan.values.toSet();
    final hasPremiumEntitlement = activeEntitlements
        .map((id) => id.trim().toLowerCase())
        .contains(SubscriptionConstants.entitlementPremium.toLowerCase());
    final hasActiveKnownSubscription =
        activeProductIds.intersection(knownProductIds).isNotEmpty;
    final hasPurchasedLifetime =
        purchasedIds.contains(SubscriptionConstants.lifetimeProductId);
    final premium = hasPremiumEntitlement ||
        hasActiveKnownSubscription ||
        hasPurchasedLifetime;
    final history = premium || purchasedIds.isNotEmpty;
    final plan = _resolvePlan(
      purchasedIds,
      info.activeSubscriptions,
      premium: premium,
    );

    isPremium.value = premium;
    hasSubscriptionHistory.value = history;
    activePlan.value = premium ? plan : 'free';

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      await _profileService.updateSubscriptionStatus(
        uid: uid,
        isPremium: premium,
        activePlan: premium ? plan : 'free',
        hasSubscriptionHistory: history,
        revenueCatAppUserId: info.originalAppUserId,
        productIds: purchasedIds,
        activeEntitlementIds: activeEntitlements,
      );
    } catch (error) {
      debugPrint('Could not sync subscription profile: $error');
    }
  }

  void _syncFromProfile(AppUserProfile? profile) {
    isPremium.value = profile?.isPremium == true;
    hasSubscriptionHistory.value = profile?.hasSubscriptionHistory == true;
    activePlan.value =
        isPremium.value ? (profile?.activePlan ?? 'premium') : 'free';
  }

  String _resolvePlan(
    List<String> purchasedProductIds,
    List<String> activeSubscriptions, {
    required bool premium,
  }) {
    final activeIds = activeSubscriptions.toSet();
    final allIds = purchasedProductIds.toSet();
    final ids = activeIds.isEmpty ? allIds : activeIds;

    if (ids.contains(SubscriptionConstants.lifetimeProductId)) {
      return 'lifetime';
    }
    if (ids.contains(SubscriptionConstants.yearlyProductId)) {
      return 'yearly';
    }
    if (ids.contains(SubscriptionConstants.monthlyProductId)) {
      return 'monthly';
    }

    return premium ? 'premium' : 'free';
  }

  String get _apiKeyForPlatform {
    if (GetPlatform.isIOS || GetPlatform.isMacOS) {
      return SubscriptionConstants.revenueCatIosApiKey.trim();
    }
    if (GetPlatform.isAndroid) {
      return SubscriptionConstants.revenueCatAndroidApiKey.trim();
    }
    return '';
  }

  @override
  void onClose() {
    if (_customerInfoListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoListener!);
    }
    _authSubscription?.cancel();
    super.onClose();
  }
}

class SubscriptionException implements Exception {
  const SubscriptionException(this.message);

  final String message;

  @override
  String toString() => message;
}
