import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          IconButton(
            onPressed: controller.skip,
            icon: const Icon(AppIcons.back, color: AppColors.primary),
          ),
          const Spacer(),
          Center(
            child: Text('your name', style: textTheme.displayMedium),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: controller.nameController,
            autofocus: true,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
            decoration: const InputDecoration(hintText: 'Amber'),
            onSubmitted: (_) => controller.finish(),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: controller.finish,
              child: Text(
                'next',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
