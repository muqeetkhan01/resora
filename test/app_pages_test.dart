import 'package:flutter_test/flutter_test.dart';

import 'package:resora/routes/app_pages.dart';
import 'package:resora/routes/app_routes.dart';

void main() {
  test('client-required screens are registered in routing', () {
    final registeredRoutes = AppPages.pages.map((page) => page.name).toSet();

    const requiredRoutes = {
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.dashboard,
      AppRoutes.journal,
      AppRoutes.chat,
      AppRoutes.spaces,
      AppRoutes.normal,
      AppRoutes.resets,
      AppRoutes.noise,
      AppRoutes.rehearse,
      AppRoutes.qa,
      AppRoutes.terms,
      AppRoutes.profile,
      AppRoutes.premium,
    };

    for (final route in requiredRoutes) {
      expect(registeredRoutes, contains(route));
    }
  });
}
