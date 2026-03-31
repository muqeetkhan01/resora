import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/spaces_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.showingLibrary.value
          ? const _SpacesLibraryView()
          : const _SpacesListView(),
    );
  }
}

class _SpacesListView extends GetView<SpacesController> {
  const _SpacesListView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeaderIcon(icon: AppIcons.back, onTap: controller.goHome),
              const Spacer(),
              _HeaderIcon(
                icon: AppIcons.profileFilled,
                onTap: controller.openProfile,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Spaces', style: textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose the kind of support that fits this moment.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(controller.spaces.length, (index) {
            final item = controller.spaces[index];
            final number = (index + 1).toString().padLeft(2, '0');

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SpaceListCard(
                number: number,
                item: item,
                onTap: () => controller.openSpace(item),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Each space starts simple, then opens into the next helpful layer only when you need it.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacesLibraryView extends GetView<SpacesController> {
  const _SpacesLibraryView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final leftCards = <SupportCardItem>[];
    final rightCards = <SupportCardItem>[];

    for (var index = 0; index < controller.supportCards.length; index++) {
      if (index.isEven) {
        leftCards.add(controller.supportCards[index]);
      } else {
        rightCards.add(controller.supportCards[index]);
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 118),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeaderIcon(
                      icon: AppIcons.back, onTap: controller.backToList),
                  const Spacer(),
                  _HeaderIcon(
                    icon: AppIcons.profileFilled,
                    onTap: controller.openProfile,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Is This Normal?', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A library of reassuring, behavior-based examples.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: leftCards
                          .map(
                            (item) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _SupportCard(
                                item: item,
                                onTap: () => controller.openLibraryCard(item),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: rightCards
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: _SupportCard(
                                  item: item,
                                  onTap: () => controller.openLibraryCard(item),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 6,
          bottom: 118,
          child: GestureDetector(
            onTap: controller.createItem,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpaceListCard extends StatelessWidget {
  const _SpaceListCard({
    required this.number,
    required this.item,
    required this.onTap,
  });

  final String number;
  final QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  number,
                  style:
                      textTheme.labelLarge?.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(item.subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.item,
    required this.onTap,
  });

  final SupportCardItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line.withOpacity(0.7)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.category,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primary.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 19,
                height: 1.2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.footer,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.primary.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                _ActionText(icon: Icons.thumb_up_alt_outlined, label: 'Relate'),
                SizedBox(width: 10),
                _ActionText(icon: Icons.bookmark_border_rounded, label: 'Save'),
                SizedBox(width: 10),
                _ActionText(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Ask',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  const _ActionText({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}
