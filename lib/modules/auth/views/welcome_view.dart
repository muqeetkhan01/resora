import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
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
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResoraLogo(size: 74, showWordmark: false),
            const SizedBox(height: AppSpacing.xxxl),
            Text(
              'Support that meets you quickly.',
              style: textTheme.displayLarge?.copyWith(fontSize: 30),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Step in with email, Google, or Apple. You can connect the real auth flow later without changing the screen structure.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                AppAssets.curtainLight,
                width: double.infinity,
                height: 248,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Continue with Email',
              icon: AppIcons.email,
              onPressed: controller.continueWithEmail,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue with Google',
              icon: AppIcons.google,
              style: AppButtonStyle.secondary,
              onPressed: controller.continueWithGoogle,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue with Apple',
              icon: AppIcons.apple,
              style: AppButtonStyle.secondary,
              onPressed: controller.continueWithApple,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: AppButton(
                label: 'Sign In',
                style: AppButtonStyle.ghost,
                expanded: false,
                onPressed: controller.signIn,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Private by design. No backend is connected yet in this UI build.',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
