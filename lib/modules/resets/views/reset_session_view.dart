import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/minimal_audio_bar.dart';

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
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(option.title, style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      'Breathe in.\nHold.\nBreathe out.',
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Stay with one instruction at a time. You do not need to solve the whole moment from here.',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              MinimalAudioBar(
                primaryLabel: option.duration,
                secondaryLabel: 'guided audio',
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Get.offNamed(AppRoutes.thatMattered),
                child: Text(
                  'continue',
                  style:
                      textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
