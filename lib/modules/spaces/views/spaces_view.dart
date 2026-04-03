import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/link_action_row.dart';
import '../controllers/spaces_controller.dart';

class SpacesView extends GetView<SpacesController> {
  const SpacesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.forest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: controller.goHome,
                    icon: const Icon(AppIcons.back, color: AppColors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.openProfile,
                    icon: const Icon(AppIcons.profileFilled,
                        color: AppColors.white),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'space',
                style: textTheme.displayLarge?.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A quieter library of support tools, terms, and next steps.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.72),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ...controller.spaces.map(
                (item) => _SpaceRow(
                  item: item,
                  onTap: () => controller.openSpace(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceRow extends StatelessWidget {
  const _SpaceRow({
    required this.item,
    required this.onTap,
  });

  final QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title.toLowerCase(),
            style: textTheme.headlineMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          LinkActionRow(
            label: 'open',
            color: AppColors.white,
            onTap: onTap,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.white.withOpacity(0.16), height: 1),
        ],
      ),
    );
  }
}
