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
  int _active = 0;

  static const double _cardWidth = 280;
  static const double _cardGap = 16;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.712);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
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

          if (_active >= slots.length && slots.isNotEmpty) {
            _active = 0;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'spaces',
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          color: const Color(0xFF4A342B),
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
                        color: Color(0xFF4A342B),
                        size: 20,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  height: 0.5,
                  color: const Color(0x1F145C4F),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 548,
                child: PageView.builder(
                  controller: _pageController,
                  padEnds: true,
                  itemCount: slots.length,
                  onPageChanged: (value) => setState(() => _active = value),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: _cardGap / 2),
                      child: _SpaceCard(
                        slot: slot,
                        width: _cardWidth,
                        onTap: () {
                          if (_active != index) {
                            _scrollTo(index);
                            return;
                          }
                          slot.onTap?.call();
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slots.length, (i) {
                  final selected = i == _active;
                  return GestureDetector(
                    onTap: () => _scrollTo(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: selected ? 20 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF145C4F)
                            : const Color(0x1F145C4F),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
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
    required this.width,
    required this.onTap,
  });

  final _ResolvedSpaceSlot slot;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBF9),
          border: Border.all(color: const Color(0x1F145C4F), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 380,
              width: double.infinity,
              child: _SpaceImage(imagePath: slot.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                  Container(
                    width: 32,
                    height: 0.5,
                    color: AppColors.terracotta,
                  ),
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
    final fallback = Image.asset(
      AppAssets.homeComingSoonFlower,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => fallback,
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
        'Short pauses that help you step back, breathe, and return to yourself.',
    defaultImage: AppAssets.spaceGarden,
  ),
  _SpaceSpec(
    route: AppRoutes.journal,
    titleHint: 'journal',
    defaultTitle: 'Journal Prompts',
    defaultSubtitle: 'Questions that dig deeper. Reflection without judgment.',
    defaultImage: AppAssets.homeJournalBed,
  ),
  _SpaceSpec(
    route: AppRoutes.rehearse,
    titleHint: 'rehearse',
    defaultTitle: 'Rehearse the Moment',
    defaultSubtitle:
        'See it clearly. Mental rehearsal that readies your mind for what comes next.',
    defaultImage: AppAssets.spaceMountain,
  ),
  _SpaceSpec(
    route: AppRoutes.noise,
    titleHint: 'noise',
    defaultTitle: 'Quiet the Noise',
    defaultSubtitle:
        'Ambient audio designed to calm your nervous system. Let sound become your anchor.',
    defaultImage: AppAssets.spaceRoom,
  ),
  _SpaceSpec(
    route: AppRoutes.terms,
    titleHint: 'term',
    defaultTitle: 'Key Terms',
    defaultSubtitle:
        'Understand the language we use. Clear definitions for everyday concepts in Resora.',
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
    subtitle:
        item.subtitle.trim().isEmpty ? spec.defaultSubtitle : item.subtitle,
    imagePath: item.imagePath ?? spec.defaultImage,
    onTap: () => controller.openSpace(item),
  );
}
