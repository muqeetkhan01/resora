import 'package:get/get.dart';

import '../modules/chat/controllers/chat_controller.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/journal/controllers/journal_controller.dart';
import '../modules/journal/views/journal_view.dart';
import '../modules/noise/controllers/noise_controller.dart';
import '../modules/noise/views/noise_view.dart';
import '../modules/normal/controllers/normal_controller.dart';
import '../modules/normal/views/normal_view.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/premium/controllers/premium_controller.dart';
import '../modules/premium/views/premium_view.dart';
import '../modules/profile/controllers/profile_controller.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/qa/controllers/qa_controller.dart';
import '../modules/qa/views/qa_view.dart';
import '../modules/rehearse/controllers/rehearse_controller.dart';
import '../modules/rehearse/views/rehearse_view.dart';
import '../modules/resets/controllers/resets_controller.dart';
import '../modules/resets/views/resets_view.dart';
import '../modules/spaces/controllers/spaces_controller.dart';
import '../modules/spaces/views/spaces_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/terms/controllers/terms_controller.dart';
import '../modules/terms/views/terms_view.dart';
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
      name: AppRoutes.resets,
      page: ResetsView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(ResetsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.noise,
      page: NoiseView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(NoiseController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.rehearse,
      page: RehearseView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(RehearseController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.terms,
      page: TermsView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(TermsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.qa,
      page: QaView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(QaController.new);
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
      name: AppRoutes.premium,
      page: PremiumView.new,
      binding: BindingsBuilder(() {
        Get.lazyPut(PremiumController.new);
      }),
    ),
  ];
}
