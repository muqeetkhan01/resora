import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIcon(
                icon: AppIcons.help,
                onTap: controller.openInfo,
              ),
              const Spacer(),
              _HeaderIcon(
                icon: AppIcons.profileFilled,
                onTap: controller.openProfile,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${controller.greeting}, ${controller.userName}',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.primary.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SectionIntro(
            title: 'Support Starts Here',
            subtitle: 'Calm guidance in the moments that matter',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditorialFeature(
            title: null,
            subtitle: null,
            imagePath: AppAssets.curtainLight,
            primaryLabel: 'Help Me Now',
            onPrimaryTap: controller.openHelpNow,
          ),
          const SizedBox(height: AppSpacing.xl),
          // const _MiniSectionTitle(title: 'Quick access'),
          // const SizedBox(height: AppSpacing.sm),
          // SizedBox(
          //   height: 118,
          //   child: ListView.separated(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: controller.quickActions.length,
          //     separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          //     itemBuilder: (context, index) {
          //       final item = controller.quickActions[index];
          //       return _QuickAccessCard(
          //         item: item,
          //         onTap: () => controller.openQuickAction(item),
          //       );
          //     },
          //   ),
          // ),
          // const SizedBox(height: AppSpacing.xl),
          const _MiniSectionTitle(title: 'Daily affirmation'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              controller.affirmation,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const _SectionIntro(
            title: 'Journal',
            subtitle: 'A quiet space to reflect and reset',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditorialFeature(
            title: null,
            subtitle: null,
            imagePath: AppAssets.journalBed,
            primaryLabel: 'Open Journal',
            onPrimaryTap: controller.openJournal,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _MiniSectionTitle(title: 'Recent journal'),
          const SizedBox(height: AppSpacing.sm),
          _RecentJournalCard(
            entry: controller.recentJournal,
            onTap: controller.openJournal,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const _SectionIntro(
            title: 'Is this normal',
            subtitle: 'Support and perspective for life’s uncertain moments.',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditorialFeature(
            title: null,
            subtitle: null,
            imagePath: AppAssets.archway,
            primaryLabel: 'Open Is This Normal',
            onPrimaryTap: () =>
                controller.openQuickAction(controller.quickActions.first),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          GestureDetector(
            onTap: controller.openPremium,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Unlock full audio, unlimited support, and deeper journal tools.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.warmDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'See plans',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          const _SectionIntro(
            title: 'Coming Soon',
            subtitle: 'Track patterns, progress, and growth',
          ),
        ],
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.item,
    required this.onTap,
  });

  final QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              item.title,
              style: textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primary.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialFeature extends StatelessWidget {
  const _EditorialFeature({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primaryLabel,
    required this.onPrimaryTap,
  });

  final String? title;
  final String? subtitle;
  final String imagePath;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            imagePath,
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
          ),
        ),
        if (title != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            title!,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary.withOpacity(0.55),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: primaryLabel,
            onPressed: onPrimaryTap,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(16),
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
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.warmDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSectionTitle extends StatelessWidget {
  const _MiniSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary.withOpacity(0.5),
            fontSize: 13,
          ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.displayMedium?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.primary.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
