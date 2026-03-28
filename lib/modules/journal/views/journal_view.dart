import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../../../widgets/section_header.dart';
import '../controllers/journal_controller.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Journal', style: textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'A gentle place to write what is true today.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8E8DD), Color(0xFFFDF7F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prompt of the day', style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(controller.promptOfTheDay,
                    style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                const AppButton(
                  label: 'Create new entry',
                  icon: Icons.edit_note_rounded,
                  onPressed: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
              title: 'Mood tags', subtitle: 'Name the tone of this season'),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: controller.moods
                  .map(
                    (mood) => AppTagChip(
                      label: mood,
                      selected: controller.selectedMood.value == mood,
                      onTap: () => controller.selectMood(mood),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Recent entries'),
          const SizedBox(height: AppSpacing.md),
          ...controller.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child:
                                Text(entry.title, style: textTheme.titleLarge)),
                        Text(entry.date, style: textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(entry.preview, style: textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: entry.moods
                          .map((tag) => AppTagChip(label: tag))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
