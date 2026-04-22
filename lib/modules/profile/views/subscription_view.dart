import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/profile_controller.dart';

class SubscriptionView extends GetView<ProfileController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'subscription'),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.primary.withOpacity(0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('current plan', style: textTheme.bodySmall),
                      Text(
                        controller.isPremium.value ? 'Resora Premium' : 'Free',
                        style: textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'plans',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.placeholder,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(
                () => Column(
                  children: [
                    _PlanCard(
                      title: 'Free',
                      subtitle: 'Always free',
                      selected: controller.activePlan.value == 'free',
                      features: const [
                        '3 journal prompts per day',
                        'Limited gentle resets',
                        'Community access',
                      ],
                      onTap: () => controller.setPlan('free'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PlanCard(
                      title: 'Premium',
                      subtitle: '\$9.99 / month · or \$79.99 / year',
                      selected: controller.activePlan.value == 'premium',
                      badge: 'most popular',
                      features: const [
                        'Unlimited journal prompts',
                        'All gentle resets + Rehearse',
                        'Talk to Resora (AI)',
                        'Space library — full access',
                        'Priority support',
                      ],
                      onTap: () => controller.setPlan('premium'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => controller.setPlan(
                        controller.isPremium.value ? 'free' : 'premium'),
                    style: FilledButton.styleFrom(
                      backgroundColor: controller.isPremium.value
                          ? Colors.transparent
                          : AppColors.primary,
                      foregroundColor: controller.isPremium.value
                          ? AppColors.primary
                          : AppColors.white,
                      side: controller.isPremium.value
                          ? const BorderSide(color: AppColors.primary)
                          : null,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      controller.isPremium.value
                          ? 'downgrade to free'
                          : 'start premium',
                      style: textTheme.bodySmall?.copyWith(
                        color: controller.isPremium.value
                            ? AppColors.primary
                            : AppColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'restore purchase',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.features,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: textTheme.titleLarge),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.terracotta),
                    ),
                    child: Text(
                      badge!,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.terracotta,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            ...features.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('— $item', style: textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
