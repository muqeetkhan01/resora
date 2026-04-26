import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      if (!controller.hasSlides) {
        return const Scaffold(
          backgroundColor: AppColors.canvas,
          body: SizedBox.shrink(),
        );
      }

      final step = controller.currentIndex.value;
      final slide = controller.slides[step];

      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'resora',
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.skip,
                      child: Text(
                        'skip',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.placeholder,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: slide.accentColor.withOpacity(0.28),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        slide.icon,
                        color: AppColors.primary.withOpacity(0.85),
                        size: 18,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        slide.caption.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        slide.title,
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 46,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        slide.subtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.warmDark.withOpacity(0.84),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                Row(
                  children: List.generate(
                    controller.slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: index == step ? 24 : 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: index == step
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      controller.isLastSlide ? 'continue' : 'next',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
