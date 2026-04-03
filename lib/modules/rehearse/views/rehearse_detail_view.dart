import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/minimal_audio_bar.dart';

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
              '“I was overloaded and I do not want to keep talking at that level.”',
          steps: ['Start with one sentence.', 'Name what you need next.'],
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
              Text(scenario.title, style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('reframe', style: textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        scenario.reframe,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('try saying', style: textTheme.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        scenario.script,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...scenario.steps.map(
                        (step) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            step,
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const MinimalAudioBar(
                primaryLabel: 'spoken guidance',
                secondaryLabel: 'prototype player',
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
