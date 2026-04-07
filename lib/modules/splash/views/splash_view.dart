import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller;

    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      safeArea: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RESORA',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 3.2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'resora',
              style: textTheme.displayLarge?.copyWith(
                fontSize: 52,
                height: 0.98,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'for real life moments',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
