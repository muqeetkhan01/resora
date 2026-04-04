import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';

class RehearseDetailView extends StatelessWidget {
  const RehearseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final scenario = Get.arguments as RehearsalScenario? ??
        const RehearsalScenario(
          title: 'Talking to my partner after a hard night',
          category: 'Relationships',
          reframe:
              'You do not need a perfect explanation. You need a clear sentence.',
          script:
              '“I was overloaded and I do not want to keep talking at that level. Can we try this again more calmly tonight?”',
          steps: [],
        );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
                  AppColors.white.withOpacity(0.08),
                  AppColors.canvas.withOpacity(0.16),
                  AppColors.canvas.withOpacity(0.52),
                  AppColors.canvas.withOpacity(0.92),
                  AppColors.canvas,
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
                  IconButton(
                    onPressed: Get.back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(AppIcons.back, color: AppColors.white),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.title,
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          scenario.reframe,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.placeholder,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          scenario.script,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.warmDark,
                            height: 1.85,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () => Get.offNamed(AppRoutes.thatMattered),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      child: const Padding(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.terracotta,
                          size: 26,
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
