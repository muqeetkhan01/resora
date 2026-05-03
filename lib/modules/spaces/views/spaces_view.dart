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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(() {
          final normal = _resolveSlot(
            route: AppRoutes.normal,
            titleHint: 'normal',
            defaultTitle: 'is this normal?',
            defaultSubtitle:
                'Short, reassuring answers from people who felt it too',
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
            defaultSubtitle: 'Plain language definitions',
            defaultImage: AppAssets.homeComingSoonFlower,
          );
          final rehearse = _resolveSlot(
            route: AppRoutes.rehearse,
            titleHint: 'rehearse',
            defaultTitle: 'rehearse the moment',
            defaultSubtitle: 'Prepare for what is coming',
            defaultImage: AppAssets.spaceMountain,
          );
          final journal = _resolveSlot(
            route: AppRoutes.journal,
            titleHint: 'journal',
            defaultTitle: 'journal',
            defaultSubtitle: 'Guided reflection prompts',
            defaultImage: AppAssets.homeJournalBed,
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SpaceFeatureCard(
                  slot: normal,
                  height: 244,
                  titleSize: 30,
                  subtitleSize: 11,
                  category: 'community',
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: _SpaceFeatureCard(
                        slot: resets,
                        height: 248,
                        titleSize: 24,
                        subtitleSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: _SpaceFeatureCard(
                        slot: noise,
                        height: 248,
                        titleSize: 24,
                        subtitleSize: 9.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                _SpaceFeatureCard(
                  slot: terms,
                  height: 188,
                  titleSize: 28,
                  subtitleSize: 10,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: _SpaceFeatureCard(
                        slot: rehearse,
                        height: 214,
                        titleSize: 24,
                        subtitleSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: _SpaceFeatureCard(
                        slot: journal,
                        height: 214,
                        titleSize: 24,
                        subtitleSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
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
      return _SpaceSlot(
        title: defaultTitle.toLowerCase(),
        subtitle: defaultSubtitle,
        imagePath: defaultImage,
        onTap: () => controller.openSpace(
          QuickActionItem(
            title: defaultTitle,
            subtitle: defaultSubtitle,
            icon: AppIcons.forward,
            accentColor: AppColors.primary,
            route: route,
          ),
        ),
      );
    }

    return _SpaceSlot(
      title: item.title.toLowerCase(),
      subtitle: item.subtitle.trim().isEmpty ? defaultSubtitle : item.subtitle,
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
    required this.titleSize,
    required this.subtitleSize,
    this.category,
  });

  final _SpaceSlot slot;
  final double height;
  final double titleSize;
  final double subtitleSize;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final title = slot.title.replaceAll(' the ', '\nthe ');

    return InkWell(
      onTap: slot.onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _SpaceImage(imagePath: slot.imagePath),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.48),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        category!.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.white.withOpacity(0.74),
                                  letterSpacing: 2.2,
                                ),
                      ),
                    ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: titleSize,
                          color: AppColors.white,
                          fontStyle: FontStyle.normal,
                          height: 1.04,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    slot.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: subtitleSize,
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Icon(
                AppIcons.forward,
                size: 14,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceImage extends StatelessWidget {
  const _SpaceImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      AppAssets.homeComingSoonFlower,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
