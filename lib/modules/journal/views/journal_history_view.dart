import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/journal_history_controller.dart';

class JournalHistoryView extends GetView<JournalHistoryController> {
  const JournalHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              );
            }

            final error = controller.errorMessage.value;
            if (error != null && error.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoryHeader(
                    onBack: Get.back,
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      error,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                ],
              );
            }

            final entries = controller.entries;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoryHeader(
                  onBack: Get.back,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (entries.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No journal entries yet.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _HistoryCard(
                          entry: entry,
                          onTap: () => controller.openEntry(entry),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 15,
            color: AppColors.terracotta,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'journal history',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 26,
                  color: AppColors.primary,
                  fontStyle: FontStyle.normal,
                ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.onTap,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final promptText = (entry.prompt ?? '').trim();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (promptText.isNotEmpty) ...[
              Text(
                promptText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary.withOpacity(0.72),
                  fontStyle: FontStyle.normal,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              entry.preview,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.warmDark,
                height: 1.75,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  entry.date,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.terracotta,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
