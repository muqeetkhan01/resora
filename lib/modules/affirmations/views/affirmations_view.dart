import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../../../widgets/premium_lock_overlay.dart';
import '../controllers/affirmations_controller.dart';

class AffirmationsView extends GetView<AffirmationsController> {
  const AffirmationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hero = MockContent.affirmations.first;

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(AppIcons.back),
            ),
            Text('Affirmations', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Words to steady the inner room.',
                style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5EBDD), Color(0xFFFDF8F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily affirmation', style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(hero.text, style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(AppIcons.play, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(hero.duration, style: textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: controller.categories
                    .map(
                      (category) => AppTagChip(
                        label: category,
                        selected: controller.selectedCategory.value == category,
                        onTap: () => controller.selectCategory(category),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Column(
                children: controller.filtered
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _AffirmationCard(item: item),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffirmationCard extends GetView<AffirmationsController> {
  const _AffirmationCard({required this.item});

  final AffirmationItem item;

  @override
  Widget build(BuildContext context) {
    final isSaved = controller.saved.contains(item.text) || item.isSaved;

    return Stack(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(item.category,
                          style: Theme.of(context).textTheme.labelLarge)),
                  GestureDetector(
                    onTap: () => controller.toggleSaved(item),
                    child: Icon(
                      isSaved
                          ? AppIcons.affirmations
                          : AppIcons.emotionalSupport,
                      color: isSaved ? AppColors.blush : AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(item.text, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(AppIcons.play),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item.duration,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
        PremiumLockOverlay(show: item.isPremium),
      ],
    );
  }
}
