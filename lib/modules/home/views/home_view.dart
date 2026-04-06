import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            140,
          ),
          child: Column(
            children: [
              Text(
                'R E S O R A',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary.withOpacity(0.78),
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _HomeFeatureCard(
                imagePath: AppAssets.homeTalkOcean,
                title: 'talk to resora',
                subtitle:
                    'Ask anything. Get a clear next step, not a list of suggestions.',
                actionLabel: 'open',
                onTap: controller.openTalk,
              ),
              _HomeFeatureCard(
                imagePath: AppAssets.homeNormalStem,
                title: 'is this normal?',
                subtitle:
                    'Short, reassuring answers when you need a steadier read on the moment.',
                actionLabel: 'open',
                onTap: controller.openNormal,
              ),
              _HomeFeatureCard(
                imagePath: AppAssets.homeJournalBed,
                title: 'journal',
                subtitle: 'Reflect gently after the moment passes.',
                actionLabel: 'open',
                onTap: controller.openJournal,
              ),
              _HomeFeatureCard(
                imagePath: AppAssets.homeComingSoonFlower,
                title: 'coming soon',
                subtitle:
                    'More space, more tools, and more support screens soon.',
                actionLabel: 'preview',
                onTap: () => Get.snackbar(
                  'coming soon',
                  'More support tools are on the way.',
                  snackPosition: SnackPosition.BOTTOM,
                  colorText: AppColors.white,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: textTheme.displayMedium?.copyWith(
                fontSize: 30,
                color: AppColors.primary.withOpacity(0.86),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.placeholder,
                height: 1.8,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              actionLabel,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.muted.withOpacity(0.78),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(height: 1, color: AppColors.line),
          ],
        ),
      ),
    );
  }
}
