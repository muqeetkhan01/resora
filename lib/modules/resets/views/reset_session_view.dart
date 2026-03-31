import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';

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

    return AppBackground(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(AppIcons.close, color: AppColors.primary),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.title, style: textTheme.displayMedium),
                      const SizedBox(height: 2),
                      Text(option.duration, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.82, end: 1),
            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.08),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.24),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Breathe in. Hold. Breathe out.',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Stay with one instruction at a time. You do not need to solve the whole moment from here.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: const LinearProgressIndicator(
              value: 0.42,
              minHeight: 4,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Open journal',
            onPressed: () => Get.toNamed(AppRoutes.journalEditor),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Return home',
            style: AppButtonStyle.secondary,
            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
