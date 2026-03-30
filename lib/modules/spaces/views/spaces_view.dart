import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/spaces_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'An organized place for what you need.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(controller.spaces.length, (index) {
            final item = controller.spaces[index];
            final number = (index + 1).toString().padLeft(2, '0');

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _SpaceRow(
                number: number,
                item: item,
                onTap: () => controller.openSpace(item),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'A calm, ordered set of spaces so you can move toward the kind of support that fits the moment.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SpaceRow extends StatelessWidget {
  const _SpaceRow({
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
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number. ${item.title.toLowerCase()}',
                      style: textTheme.titleLarge?.copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 66,
              height: 86,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(17),
                ),
                gradient: LinearGradient(
                  colors: [
                    item.accentColor.withOpacity(0.12),
                    AppColors.white,
                    item.accentColor.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
