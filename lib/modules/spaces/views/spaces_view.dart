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
    final items = controller.spaces;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xl,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text('space', style: textTheme.displayLarge),
                  ),
                  IconButton(
                    onPressed: controller.openProfile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.wb_sunny_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A quieter library of support tools, terms, and next steps.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _SpaceFeatureCard(
                item: items[0],
                onTap: () => controller.openSpace(items[0]),
                height: 188,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _SpaceFeatureCard(
                      item: items[1],
                      onTap: () => controller.openSpace(items[1]),
                      height: 208,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SpaceFeatureCard(
                      item: items[2],
                      onTap: () => controller.openSpace(items[2]),
                      height: 208,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _SpaceFeatureCard(
                      item: items[3],
                      onTap: () => controller.openSpace(items[3]),
                      height: 208,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SpaceFeatureCard(
                      item: items[4],
                      onTap: () => controller.openSpace(items[4]),
                      height: 208,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _SpaceFeatureCard(
                item: items[5],
                onTap: () => controller.openSpace(items[5]),
                height: 188,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceFeatureCard extends StatelessWidget {
  const _SpaceFeatureCard({
    required this.item,
    required this.onTap,
    required this.height,
  });

  final QuickActionItem item;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Ink(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.line),
          image: item.imagePath == null
              ? null
              : DecorationImage(
                  image: AssetImage(item.imagePath!),
                  fit: BoxFit.cover,
                ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(item.imagePath == null ? 0.08 : 0.18),
                Colors.black.withOpacity(item.imagePath == null ? 0.18 : 0.58),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title.toLowerCase(),
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 23,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withOpacity(0.84),
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    AppIcons.forward,
                    size: 16,
                    color: AppColors.terracotta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
