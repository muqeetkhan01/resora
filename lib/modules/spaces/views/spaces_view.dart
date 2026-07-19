import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/spaces_controller.dart';

class SpacesView extends StatefulWidget {
  const SpacesView({super.key});

  @override
  State<SpacesView> createState() => _SpacesViewState();
}

class _SpacesViewState extends State<SpacesView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
          final slots = _specs
              .map((spec) => _resolveSlot(spec: spec, controller: controller))
              .toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Spaces',
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          color: AppColors.primary,
                          height: 1,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.openProfile,
                      icon: const Icon(
                        AppIcons.profileOutline,
                        color: AppColors.terracotta,
                        size: 20,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              //   child: Container(
              //     height: 0.5,
              //     color: const Color(0x1F145C4F),
              //   ),
              // ),
              const SizedBox(height: 80),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: false,
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _SpaceCard(
                            slot: slot,
                            onTap: () => slot.onTap?.call(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // const SizedBox(height: 150),
            ],
          );
        }),
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.slot,
    required this.onTap,
  });

  final _ResolvedSpaceSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFAFBF9),
          // border: Border.all(color: const Color(0x1F145C4F), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Get.height * 0.48,
              width: double.infinity,
              child: _SpaceImage(imagePath: slot.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                      color: const Color(0xFF4A342B),
                      height: 1.1,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Container(
                  //   width: 32,
                  //   height: 0.5,
                  //   color: AppColors.terracotta,
                  // ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    slot.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0x734A342B),
                      fontSize: 13,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
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
    final cropBottomEdge = imagePath == AppAssets.spaceGarden;
    final fallback = Image.asset(
      AppAssets.homeComingSoonFlower,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRect(
        child: Transform.scale(
          scale: cropBottomEdge ? 1.025 : 1,
          alignment: Alignment.topCenter,
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => fallback,
          ),
        ),
      );
    }

    return ClipRect(
      child: Transform.scale(
        scale: cropBottomEdge ? 1.025 : 1,
        alignment: Alignment.topCenter,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _SpaceSpec {
  const _SpaceSpec({
    required this.route,
    required this.titleHint,
    required this.defaultTitle,
    required this.defaultSubtitle,
    required this.defaultImage,
  });

  final String route;
  final String titleHint;
  final String defaultTitle;
  final String defaultSubtitle;
  final String defaultImage;
}

class _ResolvedSpaceSlot {
  const _ResolvedSpaceSlot({
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

const _specs = <_SpaceSpec>[
  _SpaceSpec(
    route: AppRoutes.resets,
    titleHint: 'reset',
    defaultTitle: 'Gentle Resets',
    defaultSubtitle:
        'Small guided pauses to help you breathe, soften, and return to yourself.',
    defaultImage: AppAssets.spaceGarden,
  ),
  _SpaceSpec(
    route: AppRoutes.journal,
    titleHint: 'journal',
    defaultTitle: 'Journal',
    defaultSubtitle: 'A place to put your thoughts down and let them settle.',
    defaultImage: AppAssets.homeJournalBed,
  ),
  _SpaceSpec(
    route: AppRoutes.rehearse,
    titleHint: 'rehearse',
    defaultTitle: 'Rehearse the Moment',
    defaultSubtitle:
        'Guided visualization audios to help you feel ready before the moment arrives.',
    defaultImage: AppAssets.spaceMountain,
  ),
  _SpaceSpec(
    route: AppRoutes.noise,
    titleHint: 'noise',
    defaultTitle: 'Quiet the Noise',
    defaultSubtitle:
        'Soft sounds to help you settle, focus, or come back to yourself.',
    defaultImage: AppAssets.spaceRoom,
  ),
  _SpaceSpec(
    route: AppRoutes.terms,
    titleHint: 'term',
    defaultTitle: 'Key Terms',
    defaultSubtitle:
        'Simple explanations for the words and ideas you\'ll see in Resora.',
    defaultImage: AppAssets.homeComingSoonFlower,
  ),
];

_ResolvedSpaceSlot _resolveSlot({
  required _SpaceSpec spec,
  required SpacesController controller,
}) {
  final item = controller.findSpaceByRoute(spec.route) ??
      controller.findSpaceByTitle(spec.titleHint);

  if (item == null) {
    return _ResolvedSpaceSlot(
      title: spec.defaultTitle,
      subtitle: spec.defaultSubtitle,
      imagePath: spec.defaultImage,
      onTap: () => controller.openSpace(
        QuickActionItem(
          title: spec.defaultTitle,
          subtitle: spec.defaultSubtitle,
          icon: AppIcons.forward,
          accentColor: AppColors.primary,
          route: spec.route,
        ),
      ),
    );
  }

  return _ResolvedSpaceSlot(
    title: item.title.trim().isEmpty ? spec.defaultTitle : item.title,
    subtitle: spec.defaultSubtitle,
    imagePath: item.imagePath ?? spec.defaultImage,
    onTap: () => controller.openSpace(item),
  );
}
