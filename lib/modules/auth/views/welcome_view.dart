import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../controllers/auth_entry_controller.dart';

class WelcomeView extends GetView<AuthEntryController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.xxl, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 84),
            Text(
              'resora',
              style: textTheme.displayLarge?.copyWith(fontSize: 42),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Text('continue', style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Continue with Apple',
              style: AppButtonStyle.secondary,
              onPressed: controller.continueWithApple,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue with Google',
              style: AppButtonStyle.secondary,
              onPressed: controller.continueWithGoogle,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue with email',
              style: AppButtonStyle.secondary,
              onPressed: controller.continueWithEmail,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: controller.signIn,
              child: Text(
                'sign in',
                style: textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
