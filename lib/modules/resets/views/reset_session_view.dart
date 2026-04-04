import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class ResetSessionView extends StatelessWidget {
  const ResetSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    final option = Get.arguments as ResetOption? ??
        const ResetOption(
          title: 'Breath reset',
          subtitle: 'A guided inhale and exhale loop',
          duration: '2 min',
          icon: AppIcons.resets,
        );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBE4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.curtainLight,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withOpacity(0.18),
                  const Color(0xFFF0E8DD).withOpacity(0.42),
                  const Color(0xFFB29176).withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(AppIcons.back, color: AppColors.white),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: 0.2,
                            minHeight: 2,
                            backgroundColor: AppColors.white.withOpacity(0.28),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '1 / 5',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.82),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  Text(
                    option.title,
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.88),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.68),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    'Take a breath and move through this one moment slowly.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.88),
                      height: 1.8,
                    ),
                  ),
                  const Spacer(flex: 4),
                  Text(
                    'when you\'re ready, continue',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withOpacity(0.68),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.thatMattered),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withOpacity(0.92),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF8F7258),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
