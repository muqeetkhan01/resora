import 'package:flutter_test/flutter_test.dart';

import 'package:resora/routes/app_pages.dart';
import 'package:resora/routes/app_routes.dart';

void main() {
  test('client-required screens are registered in routing', () {
    final registeredRoutes = AppPages.pages.map((page) => page.name).toSet();

    const requiredRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.welcome,
      AppRoutes.emailAuth,
      AppRoutes.dashboard,
      AppRoutes.journal,
      AppRoutes.journalEditor,
      AppRoutes.chat,
      AppRoutes.spaces,
      AppRoutes.normal,
      AppRoutes.resets,
      AppRoutes.resetSession,
      AppRoutes.noise,
      AppRoutes.audioPlayer,
      AppRoutes.mindfulness,
      AppRoutes.mindfulnessDetail,
      AppRoutes.rehearse,
      AppRoutes.terms,
      AppRoutes.community,
      AppRoutes.profile,
      AppRoutes.editProfile,
      AppRoutes.premium,
    };

    for (final route in requiredRoutes) {
      expect(registeredRoutes, contains(route));
    }
  });
}
