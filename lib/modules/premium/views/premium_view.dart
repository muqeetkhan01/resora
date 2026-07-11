import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_close_button.dart';
import '../controllers/premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const benefits = [
      'Unlimited Talk to Resora conversations',
      'Full access to Gentle Reset audios',
      'Full access to Rehearse the Moment audios',
      'Full access to Quiet the Noise audios',
      'Full access to Journal Prompts',
      'Early access to new features',
      'Cancel anytime',
    ];

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCloseButton(onPressed: Get.back),
            Text('Membership', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Get more from your time in Resora.\nMore space. More support. More ways to return to yourself.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits
                    .map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                benefit,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.warmDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(AppIcons.premium,
                        color: AppColors.terracotta),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Subscriptions renew automatically unless canceled in your Apple account settings.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.warmDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () {
                final plans = controller.plans;
                if (plans.isEmpty) {
                  return Text(
                    'No premium plans published yet.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.placeholder,
                    ),
                  );
                }

                return Column(
                  children: List.generate(plans.length, (index) {
                    final plan = plans[index];
                    final selected = controller.selectedPlan.value == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () => controller.selectPlan(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color:
                                selected ? AppColors.surface : AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  selected ? AppColors.primary : AppColors.line,
                              width: selected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(plan.title,
                                            style: textTheme.titleLarge),
                                        if (plan.highlight) ...[
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'Best Value',
                                              style:
                                                  textTheme.bodySmall?.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(plan.caption,
                                        style: textTheme.bodySmall),
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
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
                label: 'Explore membership', onPressed: controller.startTrial),
            const SizedBox(height: AppSpacing.md),
            Obx(
              () => controller.canShowRestore
                  ? AppButton(
                      label: controller.isBusy
                          ? 'Restoring...'
                          : 'Restore purchases',
                      style: AppButtonStyle.ghost,
                      onPressed: controller.restorePurchases,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
