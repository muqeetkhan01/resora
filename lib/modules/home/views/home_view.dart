import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const double _imageHeight = 340;
  static const double _offset = 36;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(() {
          final slots = [
            _resolveSlot(
              spec: const _HomeCardSpec(
                route: AppRoutes.chat,
                titleHint: 'talk',
                defaultTitle: 'talk to resora',
                defaultSubtitle:
                    'Ask anything. Get a clear next step, not a list of suggestions.',
                defaultImage: AppAssets.homeTalkOcean,
                cta: 'talk',
                alignRight: false,
              ),
            ),
            _resolveSlot(
              spec: const _HomeCardSpec(
                route: AppRoutes.journal,
                titleHint: 'journal',
                defaultTitle: 'journal',
                defaultSubtitle: 'Reflect gently after the moment passes.',
                defaultImage: AppAssets.homeJournalBed,
                cta: 'write',
                alignRight: true,
              ),
            ),
            _resolveSlot(
              spec: const _HomeCardSpec(
                route: AppRoutes.normal,
                titleHint: 'normal',
                defaultTitle: 'is this normal?',
                defaultSubtitle:
                    'Real moments from people figuring it out too.',
                defaultImage: AppAssets.homeNormalStem,
                cta: 'explore',
                alignRight: false,
              ),
            ),
            _resolveSlot(
              spec: const _HomeCardSpec(
                route: AppRoutes.resets,
                titleHint: 'reset',
                defaultTitle: 'gentle resets',
                defaultSubtitle: '30 seconds back to yourself, any time.',
                defaultImage: AppAssets.spaceGarden,
                cta: 'begin',
                alignRight: true,
              ),
            ),
          ];

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.line),
                    ),
                  ),
                  child: Text(
                    'R E S O R A',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primary.withOpacity(0.84),
                      letterSpacing: 4.2,
                    ),
                  ),
                ),
                for (var i = 0; i < slots.length; i++)
                  _HomeFeatureCard(
                    slot: slots[i],
                    imageHeight: _imageHeight,
                    offset: _offset,
                    isLast: i == slots.length - 1,
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    _offset,
                    AppSpacing.xxl,
                    _offset,
                    AppSpacing.lg,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.line),
                    ),
                  ),
                  child: Text(
                    'Life gets better when you do.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary.withOpacity(0.34),
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  _HomeSlot _resolveSlot({required _HomeCardSpec spec}) {
    final item = controller.findActionByRoute(spec.route) ??
        controller.findActionByTitle(spec.titleHint);
    if (item == null) {
      return _HomeSlot(
        title: spec.defaultTitle.toLowerCase(),
        subtitle: spec.defaultSubtitle,
        imagePath: spec.defaultImage,
        actionLabel: spec.cta,
        alignRight: spec.alignRight,
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

    return _HomeSlot(
      title: item.title.toLowerCase(),
      subtitle:
          item.subtitle.trim().isEmpty ? spec.defaultSubtitle : item.subtitle,
      imagePath: item.imagePath ?? spec.defaultImage,
      actionLabel: spec.cta,
      alignRight: spec.alignRight,
      onTap: () => controller.openAction(item),
    );
  }
}

class _HomeCardSpec {
  const _HomeCardSpec({
    required this.route,
    required this.titleHint,
    required this.defaultTitle,
    required this.defaultSubtitle,
    required this.defaultImage,
    required this.cta,
    required this.alignRight,
  });

  final String route;
  final String titleHint;
  final String defaultTitle;
  final String defaultSubtitle;
  final String defaultImage;
  final String cta;
  final bool alignRight;
}

class _HomeSlot {
  const _HomeSlot({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.actionLabel,
    required this.alignRight,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String actionLabel;
  final bool alignRight;
  final VoidCallback? onTap;
}

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.slot,
    required this.imageHeight,
    required this.offset,
    required this.isLast,
  });

  final _HomeSlot slot;
  final double imageHeight;
  final double offset;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textAlign = slot.alignRight ? TextAlign.right : TextAlign.left;

    return InkWell(
      onTap: slot.onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppColors.line,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: imageHeight,
              margin: EdgeInsets.only(
                left: slot.alignRight ? offset : 0,
                right: slot.alignRight ? 0 : offset,
              ),
              child: _HomeImage(imagePath: slot.imagePath),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                offset,
                AppSpacing.xl,
                offset,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: slot.alignRight
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    textAlign: textAlign,
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w300,
                      color: AppColors.primary.withOpacity(0.9),
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    slot.subtitle,
                    textAlign: textAlign,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.placeholder,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    slot.actionLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.terracotta,
                      letterSpacing: 1.4,
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

class _HomeImage extends StatelessWidget {
  const _HomeImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      AppAssets.homeComingSoonFlower,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    final image =
        imagePath.startsWith('http://') || imagePath.startsWith('https://')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => fallback,
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => fallback,
              );

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.06),
                Colors.black.withOpacity(0.14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
