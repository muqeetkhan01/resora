import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../controllers/premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const benefits = [
      'Unlimited AI guidance and deeper reflection flows',
      'Premium meditations, ASMR sessions, and visualizations',
      'Expert answer previews and curated care collections',
      'Saved content, ritual playlists, and personalized pathways',
    ];

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Text('Resora Premium', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A soft-luxury membership for deeper care, calmer rhythms, and more support.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9D4B1), Color(0xFFC9975D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: benefits
                    .map(
                      (benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                benefit,
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white),
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Locked preview', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Healing series, expert Q&A, sleep sessions, deeper affirmations, and personalized rituals are ready for your future subscription flow.',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Column(
                children: List.generate(controller.plans.length, (index) {
                  final plan = controller.plans[index];
                  final selected = controller.selectedPlan.value == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: GestureDetector(
                      onTap: () => controller.selectPlan(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.black87
                              : Colors.white.withOpacity(0.8),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: selected ? Colors.black87 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.title,
                                    style: textTheme.titleLarge?.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    plan.caption,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: selected
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              plan.price,
                              style: textTheme.headlineMedium?.copyWith(
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const AppButton(label: 'Start premium trial', onPressed: null),
            const SizedBox(height: AppSpacing.md),
            const AppButton(
              label: 'Restore purchases',
              style: AppButtonStyle.ghost,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
