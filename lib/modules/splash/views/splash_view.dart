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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 240,
                child: Lottie.asset(
                  AppAssets.lottieIntroOption2,
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'for real life moments',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
