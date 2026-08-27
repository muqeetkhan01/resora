abstract final class SubscriptionConstants {
  static const revenueCatIosApiKey = String.fromEnvironment(
    'REVENUECAT_IOS_API_KEY',
    defaultValue: 'appl_AhJRYMUFoLKfHqHTeQIPVBbEiQy',
  );
  static const revenueCatAndroidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_API_KEY',
    defaultValue: 'goog_uErrurDufwEfdLLrUinjFBOBKhu',
  );

  static const currentOfferingId = 'default';
  static const entitlementPremium = 'premium';

  static const monthlyProductId = 'resora_monthly';
  static const yearlyProductId = 'resora_yearly';
  static const lifetimeProductId = 'resora_lifetime';

  static const productIdsByPlan = <String, String>{
    'monthly': monthlyProductId,
    'yearly': yearlyProductId,
    'lifetime': lifetimeProductId,
  };
}
