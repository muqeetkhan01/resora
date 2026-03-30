import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/section_header.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'resora',
                style: textTheme.labelLarge?.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              _IconCircleButton(
                icon: AppIcons.profileOutline,
                onTap: controller.openProfile,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${controller.greeting}, ${MockContent.userName}',
            style: textTheme.displayMedium?.copyWith(
              color: AppColors.warmDark,
              height: 1.18,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Support for the moment you are in.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PrimarySupportCard(
            snippet: controller.primary,
            onTalkTap: controller.openHelpNow,
            onResetTap: () => controller.openQuickAction(controller.quickActions[1]),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(
            title: 'spaces',
            subtitle: 'Start with one clear next step',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.quickActions.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = controller.quickActions[index];

                return SizedBox(
                  width: 164,
                  child: _QuickAccessCard(
                    number: (index + 1).toString().padLeft(2, '0'),
                    item: item,
                    onTap: () => controller.openQuickAction(item),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'today'),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 7),
                  decoration: const BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    controller.affirmation,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'recent journal',
            subtitle: 'Pick up where you left off',
            actionLabel: 'open',
            onAction: controller.openJournal,
          ),
          const SizedBox(height: AppSpacing.md),
          _RecentJournalCard(
            entry: controller.recentJournal,
            onTap: controller.openJournal,
          ),
          const SizedBox(height: AppSpacing.xxl),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'premium',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Unlock unlimited talk support, full audio, and guided reflection.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  AppIcons.premium,
                  color: AppColors.terracotta,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimarySupportCard extends StatelessWidget {
  const _PrimarySupportCard({
    required this.snippet,
    required this.onTalkTap,
    required this.onResetTap,
  });

  final HomeSnippet snippet;
  final VoidCallback onTalkTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(snippet.label.toLowerCase(), style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            snippet.title,
            style: textTheme.displayMedium?.copyWith(
              color: AppColors.primary,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            snippet.body,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.warmDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              AppButton(
                label: 'talk to resora',
                icon: AppIcons.chatOutline,
                onPressed: onTalkTap,
                expanded: false,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'open a reset',
                style: AppButtonStyle.secondary,
                onPressed: onResetTap,
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.number,
    required this.item,
    required this.onTap,
  });

  final String number;
  final QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                Text(number, style: textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.accentColor.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              style: textTheme.titleLarge?.copyWith(height: 1.22),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentJournalCard extends StatelessWidget {
  const _RecentJournalCard({
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
      behavior: HitTestBehavior.opaque,
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
              style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${entry.date} • ${entry.wordCount} words',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}
