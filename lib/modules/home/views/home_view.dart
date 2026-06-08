import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return _HomeCarousel(controller: Get.find<HomeController>());
  }
}

class _HomeCarousel extends StatefulWidget {
  const _HomeCarousel({required this.controller});

  final HomeController controller;

  @override
  State<_HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<_HomeCarousel> {
  late final PageController _pageController;
  Timer? _autoTimer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      final count = _specs.length;
      if (count == 0 || !_pageController.hasClients) {
        return;
      }
      final next = (_activeIndex + 1) % count;
      _goTo(next);
    });
  }

  void _goTo(int index) {
    final count = _specs.length;
    if (!_pageController.hasClients || count == 0) {
      return;
    }
    final target = ((index % count) + count) % count;
    if (target == _activeIndex) {
      return;
    }
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF181210),
      body: Obx(() {
        final slots = _specs
            .map((spec) =>
                _resolveSlot(spec: spec, controller: widget.controller))
            .toList(growable: false);

        if (_activeIndex >= slots.length && slots.isNotEmpty) {
          _activeIndex = 0;
        }

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              itemCount: slots.length,
              onPageChanged: (value) {
                setState(() => _activeIndex = value);
                _startAutoAdvance();
              },
              itemBuilder: (context, index) {
                final slot = slots[index];
                return _HomeSlide(slot: slot, textTheme: textTheme);
              },
            ),
            Positioned(
              left: 0,
              top: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _goTo(_activeIndex - 1);
                  _startAutoAdvance();
                },
              ),
            ),
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.55,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _goTo(_activeIndex + 1);
                  _startAutoAdvance();
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.xs,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _TopOverlayBar(
                onSettingsTap: widget.controller.openProfile,
              ),
            ),
            Positioned(
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
              child: _SlideProgress(
                count: slots.length,
                activeIndex: _activeIndex,
                onTap: (index) {
                  _goTo(index);
                  _startAutoAdvance();
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TopOverlayBar extends StatelessWidget {
  const _TopOverlayBar({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'resora',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white.withOpacity(0.92),
                fontSize: 19,
                letterSpacing: 3.8,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
              ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(
            AppIcons.profileOutline,
            color: AppColors.white,
            size: 18,
          ),
          visualDensity: VisualDensity.compact,
          splashRadius: 20,
        ),
      ],
    );
  }
}

class _HomeSlide extends StatelessWidget {
  const _HomeSlide({required this.slot, required this.textTheme});

  final _ResolvedHomeSlot slot;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _SlideImage(
          imagePath: slot.imagePath,
          alignment: slot.imageAlignment,
        ),
        DecoratedBox(decoration: BoxDecoration(gradient: slot.overlayGradient)),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xxxl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 1, height: 30, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    slot.label,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.white,
                      letterSpacing: 2.2,
                      fontSize: 9,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                slot.headline,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: 44,
                  height: 1.05,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.2,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 255,
                child: Text(
                  slot.subtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withOpacity(0.85),
                    height: 1.65,
                    fontSize: 13,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: slot.onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: BorderSide(color: AppColors.white.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  slot.cta,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    letterSpacing: 2.2,
                    fontSize: 10,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SlideProgress extends StatelessWidget {
  const _SlideProgress({
    required this.count,
    required this.activeIndex,
    required this.onTap,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'SWIPE TO EXPLORE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.5),
                fontSize: 8,
                letterSpacing: 1.4,
                fontStyle: FontStyle.normal,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < count; i++)
          GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: 26,
              height: 1.5,
              color: AppColors.white.withOpacity(0.22),
              child: i == activeIndex
                  ? TweenAnimationBuilder<double>(
                      key: ValueKey<int>(activeIndex),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(seconds: 6),
                      builder: (context, value, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                              color: AppColors.white.withOpacity(0.95)),
                        ),
                      ),
                    )
                  : i < activeIndex
                      ? Container(color: AppColors.white.withOpacity(0.55))
                      : null,
            ),
          ),
      ],
    );
  }
}

class _SlideImage extends StatelessWidget {
  const _SlideImage({
    required this.imagePath,
    required this.alignment,
  });

  final String imagePath;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      AppAssets.homeComingSoonFlower,
      fit: BoxFit.cover,
      alignment: alignment,
    );

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      alignment: alignment,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class _HomeSlideSpec {
  const _HomeSlideSpec({
    required this.route,
    required this.titleHint,
    required this.defaultTitle,
    required this.defaultSubtitle,
    required this.defaultImage,
    required this.label,
    required this.labelColor,
    required this.headline,
    required this.cta,
    required this.overlayGradient,
    required this.imageAlignment,
  });

  final String route;
  final String titleHint;
  final String defaultTitle;
  final String defaultSubtitle;
  final String defaultImage;
  final String label;
  final Color labelColor;
  final String headline;
  final String cta;
  final Gradient overlayGradient;
  final Alignment imageAlignment;
}

class _ResolvedHomeSlot {
  const _ResolvedHomeSlot({
    required this.label,
    required this.labelColor,
    required this.headline,
    required this.subtitle,
    required this.cta,
    required this.imagePath,
    required this.overlayGradient,
    required this.imageAlignment,
    required this.onTap,
  });

  final String label;
  final Color labelColor;
  final String headline;
  final String subtitle;
  final String cta;
  final String imagePath;
  final Gradient overlayGradient;
  final Alignment imageAlignment;
  final VoidCallback? onTap;
}

const _specs = <_HomeSlideSpec>[
  _HomeSlideSpec(
    route: AppRoutes.chat,
    titleHint: 'talk',
    defaultTitle: 'talk to resora',
    defaultSubtitle: 'A companion that listens and gives real answers.',
    defaultImage: AppAssets.homeTalkOcean,
    label: 'TALK TO RESORA',
    labelColor: Color(0xFF8AACB8),
    headline: 'Talk it out\nwith Resora.',
    cta: 'TALK',
    overlayGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x850E1216),
        Color(0x1F0E1216),
        Color(0x990E1216),
        Color(0xEA0A0E12),
      ],
      stops: [0, 0.32, 0.62, 1],
    ),
    imageAlignment: Alignment(0, -0.2),
  ),
  _HomeSlideSpec(
    route: AppRoutes.resets,
    titleHint: 'reset',
    defaultTitle: 'gentle resets',
    defaultSubtitle: 'Short guided meditations for real days.',
    defaultImage: AppAssets.spaceGarden,
    label: 'GUIDED RESETS',
    labelColor: AppColors.terracotta,
    headline: 'You don\'t have\nto earn rest.',
    cta: 'BEGIN',
    overlayGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xA6140C08),
        Color(0x38140C08),
        Color(0xA6140C08),
        Color(0xF0160A06),
      ],
      stops: [0, 0.30, 0.62, 1],
    ),
    imageAlignment: Alignment(0, -0.1),
  ),
  _HomeSlideSpec(
    route: AppRoutes.journal,
    titleHint: 'journal',
    defaultTitle: 'journal',
    defaultSubtitle: 'Prompts to start, space to keep going.',
    defaultImage: AppAssets.homeJournalBed,
    label: 'JOURNAL',
    labelColor: Color(0xFFC4A96A),
    headline: 'A place to think\non paper.',
    cta: 'START WRITING',
    overlayGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x940A140E),
        Color(0x260A140E),
        Color(0x9E0A140E),
        Color(0xED08100A),
      ],
      stops: [0, 0.35, 0.62, 1],
    ),
    imageAlignment: Alignment(0, 0.1),
  ),
];

_ResolvedHomeSlot _resolveSlot({
  required _HomeSlideSpec spec,
  required HomeController controller,
}) {
  final item = controller.findActionByRoute(spec.route) ??
      controller.findActionByTitle(spec.titleHint);

  if (item == null) {
    return _ResolvedHomeSlot(
      label: spec.label,
      labelColor: spec.labelColor,
      headline: spec.headline,
      subtitle: spec.defaultSubtitle,
      cta: spec.cta,
      imagePath: spec.defaultImage,
      overlayGradient: spec.overlayGradient,
      imageAlignment: spec.imageAlignment,
      onTap: () => controller.openAction(
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

  return _ResolvedHomeSlot(
    label: spec.label,
    labelColor: spec.labelColor,
    headline: spec.headline,
    subtitle:
        item.subtitle.trim().isEmpty ? spec.defaultSubtitle : item.subtitle,
    cta: spec.cta,
    imagePath: item.imagePath ?? spec.defaultImage,
    overlayGradient: spec.overlayGradient,
    imageAlignment: spec.imageAlignment,
    onTap: () => controller.openAction(item),
  );
}
