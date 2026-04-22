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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            0,
            AppSpacing.lg,
            0,
            140,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  'R E S O R A',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.78),
                        letterSpacing: 4,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Obx(() {
                final talk = _resolveSlot(
                  route: AppRoutes.chat,
                  titleHint: 'talk',
                  defaultTitle: 'talk to resora',
                  defaultSubtitle:
                      'Ask anything. Get a clear next step, not a list of suggestions.',
                  defaultImage: AppAssets.homeTalkOcean,
                );
                final normal = _resolveSlot(
                  route: AppRoutes.normal,
                  titleHint: 'normal',
                  defaultTitle: 'is this normal?',
                  defaultSubtitle:
                      'Short, reassuring answers when you need a steadier read on the moment.',
                  defaultImage: AppAssets.homeNormalStem,
                );
                final journal = _resolveSlot(
                  route: AppRoutes.journal,
                  titleHint: 'journal',
                  defaultTitle: 'journal',
                  defaultSubtitle: 'Reflect gently after the moment passes.',
                  defaultImage: AppAssets.homeJournalBed,
                );
                final comingSoon = _resolveSlot(
                  route: '',
                  titleHint: 'coming',
                  defaultTitle: 'coming soon',
                  defaultSubtitle:
                      'More space, more tools, and more support screens soon.',
                  defaultImage: AppAssets.homeComingSoonFlower,
                );

                return Column(
                  children: [
                    _HomeFeatureCard(slot: talk),
                    _HomeFeatureCard(slot: normal),
                    _HomeFeatureCard(slot: journal),
                    _HomeFeatureCard(slot: comingSoon),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  _HomeSlot _resolveSlot({
    required String route,
    required String titleHint,
    required String defaultTitle,
    required String defaultSubtitle,
    required String defaultImage,
  }) {
    final item = route.isEmpty
        ? controller.findActionByTitle(titleHint)
        : controller.findActionByRoute(route);
    if (item == null) {
      final hasRouteContent = controller.hasContentForRoute(route);
      return _HomeSlot(
        title: defaultTitle.toLowerCase(),
        subtitle: hasRouteContent ? defaultSubtitle : 'No content yet.',
        imagePath: defaultImage,
        actionLabel: hasRouteContent ? 'open' : 'no content',
        onTap: hasRouteContent
            ? () => controller.openAction(
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

    return _HomeSlot(
      title: item.title.toLowerCase(),
      subtitle: item.subtitle,
      imagePath: item.imagePath ?? defaultImage,
      actionLabel: 'open',
      onTap: () => controller.openAction(item),
    );
  }
}

class _HomeSlot {
  const _HomeSlot({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String actionLabel;
  final VoidCallback? onTap;
}

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.slot,
  });

  final _HomeSlot slot;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: slot.onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.9,
              child: _HomeImage(imagePath: slot.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: 30,
                      color: AppColors.primary.withOpacity(0.86),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    slot.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.placeholder,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    slot.actionLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(height: 1, color: AppColors.line),
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
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => Image.asset(
          AppAssets.homeComingSoonFlower,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }
}
