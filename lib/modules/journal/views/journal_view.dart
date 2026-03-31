import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
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
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal', style: textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reflect after the moment passes.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              AppAssets.journalBed,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'New entry',
                  onPressed: () => controller.openEditor(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Free write',
                  style: AppButtonStyle.secondary,
                  onPressed: () => controller.openEditor(),
                ),
              ),
            ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prompt of the day', style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  controller.promptOfTheDay,
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          Text('Recent entries', style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          ...controller.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _EntryCard(
                entry: entry,
                onTap: () => controller.openEditor(entry: entry),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              'Guided journal reflection, search, and export are ready for Premium later.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
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
            Row(
              children: [
                Text(entry.date, style: textTheme.bodySmall),
                const Spacer(),
                Text('${entry.wordCount} words', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(entry.title, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.preview,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
            ),
          ],
        ),
      ),
    );
  }
}
