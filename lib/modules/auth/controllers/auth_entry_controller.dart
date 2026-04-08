import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';

class AuthEntryController extends GetxController {
  final _session = Get.find<AppSessionController>();
  final isSubmitting = false.obs;
  final activeProvider = RxnString();

  void continueWithEmail() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signup');
  }

  Future<void> continueWithGoogle() async {
    await _runProviderAction(
      provider: 'google',
      action: _session.signInWithGoogle,
    );
  }

  Future<void> continueWithApple() async {
    await _runProviderAction(
      provider: 'apple',
      action: _session.signInWithApple,
    );
  }

  void signIn() {
    Get.toNamed(AppRoutes.emailAuth, arguments: 'signin');
  }

  void enterApp() {
    _session.completeAuth();
  }

  Future<void> _runProviderAction({
    required String provider,
    required Future<void> Function() action,
  }) async {
    if (isSubmitting.value) {
      return;
    }

    try {
      isSubmitting.value = true;
      activeProvider.value = provider;
      await action();
      _session.completeAuth();
    } catch (error) {
      showAppSnackbar(
        'Sign in failed',
        _session.describeError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      activeProvider.value = null;
      isSubmitting.value = false;
    }
  }
}
