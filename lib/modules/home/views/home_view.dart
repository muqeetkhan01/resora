import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final featureHeight =
                (constraints.maxWidth * 1.24).clamp(320.0, 530.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                0,
                0,
                0,
                140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeImageFeature(
                    imagePath: AppAssets.curtainLight,
                    height: featureHeight,
                    alignment: Alignment.center,
                    title: 'talk to resora',
                    subtitle: '"what do I need right now?"',
                    onTap: controller.openTalk,
                    fullBleed: true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _HomeImageFeature(
                    imagePath: AppAssets.journalBed,
                    height: featureHeight,
                    alignment: Alignment.center,
                    title: 'journal',
                    subtitle: '"what breathed?"',
                    onTap: controller.openJournal,
                    fullBleed: true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _HomeImageFeature(
                    imagePath: AppAssets.archway,
                    height: featureHeight,
                    alignment: Alignment.center,
                    title: 'quiet the noise',
                    subtitle: '"lower the room a little"',
                    onTap: controller.openNoise,
                    fullBleed: true,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _HomeImageFeature(
                    imagePath: AppAssets.curtainLight,
                    height: featureHeight,
                    alignment: Alignment.topCenter,
                    title: 'coming soon',
                    subtitle: '"come back soon for new features"',
                    onTap: () => Get.snackbar(
                      'coming soon',
                      'come back soon for new features',
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: AppColors.white,
                      backgroundColor: AppColors.primary,
                    ),
                    fullBleed: true,
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
    required this.imagePath,
    required this.height,
    required this.alignment,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fullBleed = false,
  });

  final String imagePath;
  final double height;
  final Alignment alignment;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            alignment: alignment,
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fullBleed ? AppSpacing.lg : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.placeholder,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    AppIcons.forward,
                    size: 20,
                    color: AppColors.terracotta,
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
