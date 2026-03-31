import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/rehearse_controller.dart';

class RehearseView extends GetView<RehearseController> {
  const RehearseView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.close, color: AppColors.primary),
              ),
              Text('rehearse the moment', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A reframe, a script, and a clear next step for the part you are dreading.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              ...controller.scenarios.map(
                (scenario) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ScenarioCard(scenario: scenario),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioCard extends GetView<RehearseController> {
  const _ScenarioCard({required this.scenario});

  final RehearsalScenario scenario;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(scenario.category, style: textTheme.labelLarge),
              if (scenario.isPremium) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'premium',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(scenario.title, style: textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: AppSpacing.md),
          Text('Here’s another way to see it', style: textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(scenario.reframe, style: textTheme.bodyLarge?.copyWith(color: AppColors.warmDark)),
          const SizedBox(height: AppSpacing.md),
          Text('Try saying', style: textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(scenario.script, style: textTheme.bodyLarge?.copyWith(color: AppColors.warmDark)),
          const SizedBox(height: AppSpacing.md),
          Text('Steps', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          ...scenario.steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(step, style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppButton(
                label: 'Save to journal',
                style: AppButtonStyle.secondary,
                onPressed: () => controller.saveToJournal(scenario),
                expanded: false,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Practice again',
                style: AppButtonStyle.ghost,
                onPressed: () => controller.practiceAgain(scenario),
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
