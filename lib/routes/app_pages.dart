import 'package:get/get.dart';

import '../modules/auth/controllers/auth_entry_controller.dart';
import '../modules/auth/controllers/email_auth_controller.dart';
import '../modules/auth/views/email_auth_view.dart';
import '../modules/auth/views/welcome_view.dart';
import '../modules/chat/controllers/chat_controller.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/community/controllers/community_controller.dart';
import '../modules/community/views/community_view.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/journal/controllers/journal_controller.dart';
import '../modules/journal/views/journal_editor_view.dart';
import '../modules/journal/views/journal_view.dart';
import '../modules/mindfulness/controllers/mindfulness_controller.dart';
import '../modules/mindfulness/views/mindfulness_detail_view.dart';
import '../modules/mindfulness/views/mindfulness_view.dart';
import '../modules/noise/controllers/noise_controller.dart';
import '../modules/noise/views/audio_player_view.dart';
import '../modules/noise/views/noise_view.dart';
import '../modules/normal/controllers/normal_controller.dart';
import '../modules/normal/views/normal_ask_view.dart';
import '../modules/normal/views/normal_view.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/premium/controllers/premium_controller.dart';
import '../modules/premium/views/premium_view.dart';
import '../modules/profile/controllers/edit_profile_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/help_support_view.dart';
import '../modules/profile/views/journal_lock_view.dart';
import '../modules/profile/views/privacy_policy_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/subscription_view.dart';
import '../modules/rehearse/controllers/rehearse_controller.dart';
import '../modules/rehearse/views/rehearse_detail_view.dart';
import '../modules/rehearse/views/rehearse_view.dart';
import '../modules/resets/controllers/resets_controller.dart';
import '../modules/resets/views/reset_session_view.dart';
import '../modules/resets/views/resets_view.dart';
import '../modules/ritual_wrap/views/ritual_wrap_view.dart';
import '../modules/spaces/controllers/spaces_controller.dart';
import '../modules/spaces/views/spaces_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/terms/controllers/terms_controller.dart';
import '../modules/terms/views/terms_view.dart';
import '../modules/that_mattered/views/that_mattered_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(SplashController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: OnboardingView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(OnboardingController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.welcome,
      page: WelcomeView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(AuthEntryController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.emailAuth,
      page: EmailAuthView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(EmailAuthController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: DashboardView.new,
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(HomeController());
        Get.put(ChatController());
        Get.put(SpacesController());
        Get.put(JournalController());
      }),
    ),
    GetPage(
      name: AppRoutes.journal,
      page: JournalView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(JournalController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.journalEditor,
      page: JournalEditorView.new,
    ),
    GetPage(
      name: AppRoutes.chat,
      page: ChatView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(ChatController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.spaces,
      page: SpacesView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(SpacesController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.normal,
      page: NormalView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(NormalController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.normalAsk,
      page: NormalAskView.new,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NormalController>()) {
          Get.put(NormalController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.resets,
      page: ResetsView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(ResetsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.resetSession,
      page: ResetSessionView.new,
    ),
    GetPage(
      name: AppRoutes.noise,
      page: NoiseView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(NoiseController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.audioPlayer,
      page: AudioPlayerView.new,
    ),
    GetPage(
      name: AppRoutes.mindfulness,
      page: MindfulnessView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(MindfulnessController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.mindfulnessDetail,
      page: MindfulnessDetailView.new,
    ),
    GetPage(
      name: AppRoutes.rehearse,
      page: RehearseView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(RehearseController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.rehearseDetail,
      page: RehearseDetailView.new,
    ),
    GetPage(
      name: AppRoutes.terms,
      page: TermsView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(TermsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.community,
      page: CommunityView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(CommunityController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: ProfileView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(ProfileController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: EditProfileView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(EditProfileController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: SubscriptionView.new,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.journalLock,
      page: JournalLockView.new,
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.helpSupport,
      page: HelpSupportView.new,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: PrivacyPolicyView.new,
    ),
    GetPage(
      name: AppRoutes.premium,
      page: PremiumView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(PremiumController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.thatMattered,
      page: ThatMatteredView.new,
    ),
    GetPage(
      name: AppRoutes.ritualWrap,
      page: RitualWrapView.new,
    ),
  ];
}
