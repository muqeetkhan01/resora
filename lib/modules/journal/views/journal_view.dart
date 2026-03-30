import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/journal_controller.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 96),
      child: Column(
        children: [
          Text('journal', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          const _JournalHero(),
          Transform.translate(
            offset: const Offset(0, -26),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('prompt of the day', style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    controller.promptOfTheDay,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'start prompted entry',
                    icon: AppIcons.journal,
                    onPressed: () {},
                    expanded: false,
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Need inspiration?\nExplore guided reflections.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(
                controller.modes.length,
                (index) => AppTagChip(
                  label: controller.modes[index].toLowerCase(),
                  selected: controller.selectedMode.value == index,
                  onTap: () => controller.selectMode(index),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('recent entries', style: textTheme.titleLarge),
          ),
          const SizedBox(height: AppSpacing.md),
          ...controller.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
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
                    Text(entry.title, style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      entry.preview,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${entry.date} • ${entry.wordCount} words',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                const Icon(AppIcons.premium, color: AppColors.terracotta, size: 18),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Guided journal and unlimited entries are available with Premium.',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalHero extends StatelessWidget {
  const _JournalHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 56),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.canvas],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 126,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(70)),
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.canvas],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: AppColors.line),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 26,
                  child: Container(
                    width: 54,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                Positioned(
                  top: 36,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
