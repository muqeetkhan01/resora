import 'package:get/get.dart';

import '../modules/affirmations/controllers/affirmations_controller.dart';
import '../modules/affirmations/views/affirmations_view.dart';
import '../modules/auth/controllers/auth_entry_controller.dart';
import '../modules/auth/views/welcome_view.dart';
import '../modules/chat/controllers/chat_controller.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/community/controllers/community_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/journal/controllers/journal_controller.dart';
import '../modules/mindfulness/controllers/mindfulness_controller.dart';
import '../modules/mindfulness/views/mindfulness_detail_view.dart';
import '../modules/mindfulness/views/mindfulness_view.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/premium/controllers/premium_controller.dart';
import '../modules/premium/views/premium_view.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/qa/controllers/qa_controller.dart';
import '../modules/qa/views/qa_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
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
      name: AppRoutes.dashboard,
      page: DashboardView.new,
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(HomeController());
        Get.put(JournalController());
        Get.put(CommunityController());
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: ChatView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(ChatController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.affirmations,
      page: AffirmationsView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(AffirmationsController.new);
      }),
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
      name: AppRoutes.qa,
      page: QaView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(QaController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.premium,
      page: PremiumView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(PremiumController.new);
      }),
    ),
  ];
}
