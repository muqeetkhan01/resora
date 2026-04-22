import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isNameStep) {
        return _NameStep(controller: controller);
      }

      final step = controller.currentIndex.value;
      final slide = controller.slides[step];

      return _SlideStep(
        controller: controller,
        slide: slide,
        step: step,
      );
    });
  }
}

class _SlideStep extends StatelessWidget {
  const _SlideStep({
    required this.controller,
    required this.slide,
    required this.step,
  });

  final OnboardingController controller;
  final OnboardingItem slide;
  final int step;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bg = slide.accentColor.withOpacity(0.16);

    return Scaffold(
      backgroundColor: bg,
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
                    style: textTheme.titleLarge?.copyWith(
                      letterSpacing: 2,
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
              Text(
                slide.caption.toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.primary.withOpacity(0.62),
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                slide.title,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.warmDark,
                  fontSize: 58,
                  height: 1.03,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                slide.subtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.warmDark.withOpacity(0.8),
                ),
              ),
              const Spacer(flex: 3),
              Row(
                children: List.generate(
                  controller.slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: index == step ? 22 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: index == step
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.2),
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
                    step == controller.slides.length - 1 ? 'continue' : 'next',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.4,
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

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              IconButton(
                onPressed: controller.back,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.terracotta,
                  size: 16,
                ),
              ),
              const Spacer(flex: 2),
              Text(
                'What should we call you?',
                style: textTheme.displayMedium?.copyWith(
                  fontSize: 38,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'This is how Resora will address you in prompts and support moments.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: controller.nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
                decoration: const InputDecoration(
                  hintText: 'your name',
                ),
                onSubmitted: (_) => controller.finish(),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.finish,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text(
                    'start',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1.4,
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
