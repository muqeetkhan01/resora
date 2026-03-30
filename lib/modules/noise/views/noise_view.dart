import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/noise_controller.dart';

class NoiseView extends GetView<NoiseController> {
  const NoiseView({super.key});

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
              Text('quiet the noise', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Audio support for calm, focus, and downshift.',
                style: textTheme.bodyMedium,
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
              const _FeaturedPlayerCard(),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => Column(
                  children: controller.tracks
                      .map(
                        (track) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _TrackCard(
                            title: track.title,
                            description: track.description,
                            meta: '${track.category} • ${track.duration}',
                            premium: track.isPremium,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(AppIcons.play, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Now playing', style: textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text('Soft rain on leaves', style: textTheme.titleMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedPlayerCard extends StatelessWidget {
  const _FeaturedPlayerCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.canvas, AppColors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(AppIcons.play, size: 44, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Soft rain on leaves', style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A steady environmental downshift for the moment your head feels too loud.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_rounded, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.replay_10_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.forward_10_rounded, color: AppColors.primary),
              const Spacer(),
              Text('18 min', style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.34,
              minHeight: 4,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.description,
    required this.meta,
    required this.premium,
  });

  final String title;
  final String description;
  final String meta;
  final bool premium;

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(AppIcons.play, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: textTheme.titleLarge)),
                    if (premium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
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
                ),
                const SizedBox(height: 4),
                Text(description, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(meta, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
