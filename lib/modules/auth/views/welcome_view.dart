import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../controllers/auth_entry_controller.dart';

class WelcomeView extends GetView<AuthEntryController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            const ResoraLogo(size: 92),
            const SizedBox(height: AppSpacing.xxxl),
            Text('Feel held, guided, and quietly supported.',
                style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'A calm, premium space for parenting, healing, mindful rituals, and support that fits into real life.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppCard(
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.94),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                children: [
                  AppButton(
                    label: 'Continue with Email',
                    icon: AppIcons.email,
                    onPressed: controller.enterApp,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Continue with Google',
                    icon: AppIcons.google,
                    style: AppButtonStyle.secondary,
                    onPressed: controller.enterApp,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Continue with Apple',
                    icon: AppIcons.apple,
                    style: AppButtonStyle.secondary,
                    onPressed: controller.enterApp,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Sign In',
                    style: AppButtonStyle.ghost,
                    onPressed: controller.enterApp,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'By continuing, you agree to a private, thoughtful experience designed to protect your data and respect your pace.',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
