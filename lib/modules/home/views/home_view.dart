import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/link_action_row.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.forest,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final featureWidth = (constraints.maxWidth * 0.72).clamp(220.0, 292.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: controller.openInfo,
                        icon: const Icon(AppIcons.help, color: AppColors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: controller.openProfile,
                        icon: const Icon(
                          AppIcons.profileFilled,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'home',
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    controller.userName.toLowerCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _HomeImageFeature(
                    width: featureWidth,
                    imagePath: AppAssets.curtainLight,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    title: 'talk to resora',
                    subtitle: '"what do I need right now?"',
                    onTap: controller.openTalk,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _HomeImageFeature(
                    width: featureWidth,
                    imagePath: AppAssets.journalBed,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    title: 'journal',
                    subtitle: '"what breathed?"',
                    onTap: controller.openJournal,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _HomeImageFeature(
                    width: featureWidth,
                    imagePath: AppAssets.archway,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    title: 'quiet the noise',
                    subtitle: '"lower the room a little"',
                    onTap: controller.openNoise,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _HomeImageFeature(
                    width: featureWidth,
                    imagePath: AppAssets.curtainLight,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    title: 'rehearse the moment',
                    subtitle: '"say it more calmly"',
                    onTap: controller.openRehearse,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeImageFeature extends StatelessWidget {
  const _HomeImageFeature({
    required this.width,
    required this.imagePath,
    required this.fit,
    required this.alignment,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              imagePath,
              width: width,
              height: width * 1.16,
              fit: fit,
              alignment: alignment,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          LinkActionRow(
            label: 'open',
            color: AppColors.white,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
