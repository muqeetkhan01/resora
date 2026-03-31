import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
          const _SectionIntro(
            title: 'Support Starts Here',
            subtitle: 'Calm guidance in the moments that matter',
          ),
          const SizedBox(height: AppSpacing.md),
          _EditorialFeature(
            title: null,
            subtitle: null,
            imagePath: AppAssets.curtainLight,
            primaryLabel: 'Talk to Resora',
            onPrimaryTap: controller.openHelpNow,
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
            onPrimaryTap: () => controller.openQuickAction(controller.quickActions.first),
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
