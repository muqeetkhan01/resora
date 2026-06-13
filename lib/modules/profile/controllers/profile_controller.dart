import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../data/models/app_user_profile.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';

class ProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();
  final _subscriptions = Get.find<SubscriptionService>();
  final _profileService = UserProfileService();

  final affirmationsEnabled = true.obs;
  final journalLockEnabled = false.obs;
  final isPremium = false.obs;
  final activePlan = 'free'.obs;
  final journalPin = RxnString();
  final journalUnlockedForSession = false.obs;

  @override
  void onInit() {
    super.onInit();
    _syncFromProfile(_session.profile);
    ever<AppUserProfile?>(_session.profileRx, _syncFromProfile);
    ever<bool>(_subscriptions.isPremium, (_) => _syncSubscriptionState());
    ever<String>(_subscriptions.activePlan, (_) => _syncSubscriptionState());
  }

  void _syncFromProfile(AppUserProfile? profile) {
    if (profile == null) {
      journalPin.value = null;
      journalLockEnabled.value = false;
      journalUnlockedForSession.value = false;
      _syncSubscriptionState();
      return;
    }

    final pin = profile.journalPin?.trim();
    journalPin.value = (pin == null || pin.isEmpty) ? null : pin;
    journalLockEnabled.value =
        profile.journalLockEnabled && (journalPin.value != null);
    journalUnlockedForSession.value = false;
    _syncSubscriptionState();
  }

  void _syncSubscriptionState() {
    final profile = _session.profile;
    final hasPremium = _subscriptions.isPremium.value ||
        (profile != null && profile.isPremium);
    isPremium.value = hasPremium;
    activePlan.value = hasPremium
        ? (_subscriptions.activePlan.value != 'free'
            ? _subscriptions.activePlan.value
            : (profile?.activePlan ?? 'premium'))
        : 'free';
  }

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void toggleAffirmations(bool value) {
    affirmationsEnabled.value = value;
  }

  void toggleJournalLock(bool value) {
    journalLockEnabled.value = value;
    if (!value) {
      journalPin.value = null;
      journalUnlockedForSession.value = false;
      _persistJournalLock();
    }
  }

  void openSubscription() {
    Get.toNamed(AppRoutes.subscription);
  }

  void openJournalLock() {
    Get.toNamed(AppRoutes.journalLock);
  }

  void openHelpSupport() {
    Get.toNamed(AppRoutes.helpSupport);
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void openTermsOfUse() {
    Get.toNamed(AppRoutes.termsOfUse);
  }

  void openDeleteAccount() {
    Get.toNamed(AppRoutes.deleteAccount);
  }

  Future<void> signOut() async {
    await _session.signOut();
  }

  bool get hasJournalPin => (journalPin.value ?? '').isNotEmpty;

  bool get requiresJournalUnlock =>
      journalLockEnabled.value &&
      hasJournalPin &&
      !journalUnlockedForSession.value;

  bool verifyJournalPin(String pin) => (journalPin.value ?? '') == pin.trim();

  void markJournalUnlocked() {
    journalUnlockedForSession.value = true;
  }

  Future<bool> ensureJournalUnlocked() async {
    if (!requiresJournalUnlock) {
      return true;
    }

    final result = await Get.toNamed(AppRoutes.journalUnlock);
    return result == true;
  }

  void setJournalPin(String pin) {
    journalPin.value = pin;
    journalLockEnabled.value = true;
    journalUnlockedForSession.value = true;
    _persistJournalLock();
  }

  void clearJournalPin() {
    journalPin.value = null;
    journalLockEnabled.value = false;
    journalUnlockedForSession.value = false;
    _persistJournalLock();
  }

  bool get canShowRestore => _subscriptions.canShowRestore;

  bool get isSubscriptionBusy =>
      _subscriptions.isLoading.value ||
      _subscriptions.isPurchasing.value ||
      _subscriptions.isRestoring.value;

  String? priceForPlan(String planId) => _subscriptions.priceForPlan(planId);

  Future<void> refreshSubscriptions() => _subscriptions.refresh();

  Future<bool> purchasePlan(String planId) async {
    try {
      final purchased = await _subscriptions.purchasePlan(planId);
      if (!purchased) {
        return false;
      }
      showAppSnackbar(
        'Premium unlocked',
        'Your Resora membership is active.',
      );
      return true;
    } on SubscriptionException catch (error) {
      showAppSnackbar('Could not start membership', error.message);
      return false;
    } catch (_) {
      showAppSnackbar(
        'Could not start membership',
        'Please try again in a moment.',
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!canShowRestore) {
      return false;
    }

    try {
      final restored = await _subscriptions.restorePurchases();
      showAppSnackbar(
        restored ? 'Restored' : 'Nothing active found',
        restored
            ? 'Your Resora premium access is active.'
            : 'We did not find an active subscription for this account.',
      );
      return restored;
    } on SubscriptionException catch (error) {
      showAppSnackbar('Could not restore', error.message);
      return false;
    } catch (_) {
      showAppSnackbar(
        'Could not restore',
        'Please try again in a moment.',
      );
      return false;
    }
  }

  Future<void> _persistJournalLock() async {
    final user = _session.firebaseUser;
    if (user == null) {
      return;
    }

    try {
      await _profileService.updateJournalLock(
        uid: user.uid,
        enabled: journalLockEnabled.value,
        pin: journalPin.value,
      );
    } catch (_) {
      showAppSnackbar(
        'Could not save lock',
        'Your journal lock change could not be saved right now.',
      );
    }
  }
}
