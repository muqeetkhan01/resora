import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.md, bottom: AppSpacing.lg),
            child: Row(
              children: [
                const FrostedPill(child: Text('Resora')),
                const Spacer(),
                TextButton(
                  onPressed: controller.skip,
                  child: const Text('Skip'),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                return _OnboardingSlide(
                    item: controller.items[index] as OnboardingItem);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.items.length, (index) {
                final selected = index == controller.currentPage.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black87 : Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Obx(
            () => AppButton(
              label: controller.currentPage.value == controller.items.length - 1
                  ? 'Enter Resora'
                  : 'Continue',
              onPressed: controller.next,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.item});

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.92),
                item.accentColor.withOpacity(0.24),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(item.icon, size: 34, color: Colors.black87),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(item.title, style: textTheme.displayMedium),
                const SizedBox(height: AppSpacing.md),
                Text(item.subtitle, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Text(item.caption, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxxl),
                _Illustration(accentColor: item.accentColor, icon: item.icon),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.accentColor,
    required this.icon,
  });

  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.28),
                borderRadius: BorderRadius.circular(42),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: BorderRadius.circular(36),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: Colors.white),
              ),
              child: Icon(icon, size: 74, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
