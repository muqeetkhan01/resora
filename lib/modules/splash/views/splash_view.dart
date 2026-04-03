import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final lottieSize = (constraints.maxWidth * 0.98).clamp(160.0, 320.0);

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: lottieSize,
                  height: lottieSize,
                  child: Lottie.asset(
                    AppAssets.lottieBreath,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Resora',
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'for real life moments',
                  style:
                      textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
