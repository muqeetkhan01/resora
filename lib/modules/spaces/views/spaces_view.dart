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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'space',
                      style: textTheme.displayLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.openProfile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'A quieter library of support tools, terms, and next steps.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.title.toLowerCase(),
                  style: textTheme.headlineMedium
                      ?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.line, height: 1),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: const Icon(AppIcons.forward,
                size: 16, color: AppColors.terracotta),
          ),
        ],
      ),
    );
  }
}
