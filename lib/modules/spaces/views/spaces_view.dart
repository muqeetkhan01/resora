import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/spaces_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('space', style: textTheme.displayLarge),
                  ),
                  IconButton(
                    onPressed: controller.openProfile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.wb_sunny_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A quieter library of support tools, terms, and next steps.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Obx(() {
                final normal = _resolveSlot(
                  route: AppRoutes.normal,
                  titleHint: 'normal',
                  defaultTitle: 'is this normal?',
                  defaultSubtitle: 'Short, reassuring answers',
                  defaultImage: AppAssets.homeNormalStem,
                );
                final resets = _resolveSlot(
                  route: AppRoutes.resets,
                  titleHint: 'reset',
                  defaultTitle: 'gentle resets',
                  defaultSubtitle: 'Breath, grounding, step away',
                  defaultImage: AppAssets.spaceGarden,
                );
                final noise = _resolveSlot(
                  route: AppRoutes.noise,
                  titleHint: 'noise',
                  defaultTitle: 'quiet the noise',
                  defaultSubtitle: 'Ambient audio and guided calm',
                  defaultImage: AppAssets.spaceRoom,
                );
                final terms = _resolveSlot(
                  route: AppRoutes.terms,
                  titleHint: 'term',
                  defaultTitle: 'key terms',
                  defaultSubtitle: 'Plain-language definitions',
                  defaultImage: AppAssets.homeComingSoonFlower,
                );
                final rehearse = _resolveSlot(
                  route: AppRoutes.rehearse,
                  titleHint: 'rehearse',
                  defaultTitle: 'rehearse the moment',
                  defaultSubtitle: 'Scripts for the hard part',
                  defaultImage: AppAssets.spaceMountain,
                );
                final journal = _resolveSlot(
                  route: AppRoutes.journal,
                  titleHint: 'journal',
                  defaultTitle: 'journal',
                  defaultSubtitle: 'Reflect after you reset',
                  defaultImage: AppAssets.homeJournalBed,
                );

                return Column(
                  children: [
                    _SpaceFeatureCard(slot: normal, height: 188),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _SpaceFeatureCard(
                            slot: resets,
                            height: 208,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SpaceFeatureCard(
                            slot: noise,
                            height: 208,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SpaceFeatureCard(slot: terms, height: 188),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _SpaceFeatureCard(
                            slot: rehearse,
                            height: 208,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SpaceFeatureCard(
                            slot: journal,
                            height: 208,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  _SpaceSlot _resolveSlot({
    required String route,
    required String titleHint,
    required String defaultTitle,
    required String defaultSubtitle,
    required String defaultImage,
  }) {
    final item = controller.findSpaceByRoute(route) ??
        controller.findSpaceByTitle(titleHint);
    if (item == null) {
      final hasRouteContent = controller.hasContentForRoute(route);
      return _SpaceSlot(
        title: defaultTitle.toLowerCase(),
        subtitle: hasRouteContent ? defaultSubtitle : 'No content yet.',
        imagePath: defaultImage,
        onTap: hasRouteContent
            ? () => controller.openSpace(
                  QuickActionItem(
                    title: defaultTitle,
                    subtitle: defaultSubtitle,
                    icon: AppIcons.forward,
                    accentColor: AppColors.primary,
                    route: route,
                  ),
                )
            : null,
      );
    }

    return _SpaceSlot(
      title: item.title.toLowerCase(),
      subtitle: item.subtitle,
      imagePath: item.imagePath ?? defaultImage,
      onTap: () => controller.openSpace(item),
    );
  }
}

class _SpaceSlot {
  const _SpaceSlot({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback? onTap;
}

class _SpaceFeatureCard extends StatelessWidget {
  const _SpaceFeatureCard({
    required this.slot,
    required this.height,
  });

  final _SpaceSlot slot;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: slot.onTap,
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.line),
          image: DecorationImage(
            image: slot.imagePath.startsWith('http://') ||
                    slot.imagePath.startsWith('https://')
                ? NetworkImage(slot.imagePath) as ImageProvider
                : AssetImage(slot.imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.18),
                Colors.black.withOpacity(0.58),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slot.title,
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 23,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          slot.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withOpacity(0.84),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    AppIcons.forward,
                    size: 16,
                    color: AppColors.terracotta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
