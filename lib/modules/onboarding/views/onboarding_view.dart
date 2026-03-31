import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:resora/core/constants/app_assets.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Obx(
        () => SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${controller.currentStep.value + 1} of ${controller.totalSteps}',
                    style:
                        textTheme.bodySmall?.copyWith(color: AppColors.primary),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.skip,
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _stepForIndex(controller.currentStep.value, context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (controller.currentStep.value < controller.totalSteps - 1)
                AppButton(
                  label: controller.currentStep.value == 0
                      ? 'Get Started'
                      : 'Continue',
                  onPressed: controller.next,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepForIndex(int index, BuildContext context) {
    return switch (index) {
      0 => const _WelcomeStep(key: ValueKey('welcome')),
      1 => _NameStep(key: const ValueKey('name'), controller: controller),
      2 => _GoalsStep(key: const ValueKey('goals'), controller: controller),
      3 => _NotificationsStep(
          key: const ValueKey('notifications'),
          controller: controller,
        ),
      _ => _PremiumIntroStep(
          key: const ValueKey('premium'),
          controller: controller,
        ),
    };
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              AppAssets.lottieBreath,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Resora', style: textTheme.displayLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Practical support for real life moments.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.warmDark),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'No noise. No long setup. Just a calmer next step.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What should we call you?', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('This keeps the app personal without adding extra setup.',
            style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: controller.nameController,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
      ],
    );
  }
}

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({
    super.key,
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What brings you to Resora?', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Choose what would help first. You can change this later.',
            style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        ...controller.goals.map(
          (goal) => Obx(
            () => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SelectableGoalRow(
                title: goal.title,
                subtitle: goal.subtitle,
                selected: controller.selectedGoals.contains(goal.title),
                onTap: () => controller.toggleGoal(goal.title),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({
    super.key,
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Want one daily affirmation?', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Short. Direct. Easy to change later.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Obx(
            () => SwitchListTile.adaptive(
              value: controller.notificationsEnabled.value,
              onChanged: controller.toggleNotifications,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable affirmations',
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                'Morning, midday, evening, or random',
                style: textTheme.bodySmall,
              ),
              activeColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumIntroStep extends StatelessWidget {
  const _PremiumIntroStep({
    super.key,
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Unlock everything', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Unlimited talk support, full audio, deeper journal tools, and premium spaces.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        ...MockContent.premiumPlans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: plan.highlight ? AppColors.surface : AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: plan.highlight ? AppColors.primary : AppColors.line,
                  width: plan.highlight ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title, style: textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(plan.caption, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    plan.price,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: 'Start 7-day trial', onPressed: controller.finish),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Continue free',
          style: AppButtonStyle.secondary,
          onPressed: controller.finish,
        ),
      ],
    );
  }
}

class _SelectableGoalRow extends StatelessWidget {
  const _SelectableGoalRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.line,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
