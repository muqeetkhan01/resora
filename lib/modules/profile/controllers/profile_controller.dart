import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/subscription_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';

class ProfileController extends GetxController {
  final _session = Get.find<AppSessionController>();
  final _subscriptions = Get.find<SubscriptionService>();

  final affirmationsEnabled = true.obs;
  final isPremium = false.obs;
  final activePlan = 'free'.obs;

  @override
  void onInit() {
    super.onInit();
    _syncSubscriptionState();
    ever(_session.profileRx, (_) => _syncSubscriptionState());
    ever<bool>(_subscriptions.isPremium, (_) => _syncSubscriptionState());
    ever<String>(_subscriptions.activePlan, (_) => _syncSubscriptionState());
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

  void openSubscription() {
    Get.toNamed(AppRoutes.subscription);
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

  bool get canShowRestore => _subscriptions.canShowRestore;

  bool get isSubscriptionBusy =>
      _subscriptions.isLoading.value ||
      _subscriptions.isPurchasing.value ||
      _subscriptions.isRestoring.value;

  String? priceForPlan(String planId) => _subscriptions.priceForPlan(planId);

  bool isPlanAvailable(String planId) =>
      _subscriptions.packageForPlan(planId) != null;

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
}
