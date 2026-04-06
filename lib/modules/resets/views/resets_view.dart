import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/snap_feed_indicator.dart';
import '../controllers/resets_controller.dart';

class ResetsView extends GetView<ResetsController> {
  const ResetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Obx(
        () {
          final selectedCategory = controller.selectedCategory.value;
          final currentIndex = controller.currentPage.value;
          final options = controller.filteredOptions;
          final backgroundColor = _backgroundColorFor(
            selectedCategory: selectedCategory,
            currentIndex: currentIndex,
            options: options,
          );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            color: backgroundColor,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        AppIcons.back,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('gentle reset', style: textTheme.displayMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Regulate first. Reflect later.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withOpacity(0.72),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final category = controller.categories[index];
                          final selected = selectedCategory == category;

                          return _CategoryTab(
                            label: category,
                            selected: selected,
                            onTap: () => controller.selectCategory(category),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: Stack(
                        children: [
                          PageView.builder(
                            key: ValueKey(selectedCategory),
                            scrollDirection: Axis.vertical,
                            onPageChanged: controller.setCurrentPage,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              return _ResetPage(
                                option: option,
                                onTap: () => controller.openReset(option),
                              );
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: SnapFeedIndicator(
                                count: options.length,
                                currentIndex: currentIndex,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _backgroundColorFor({
    required String selectedCategory,
    required int currentIndex,
    required List<ResetOption> options,
  }) {
    if (selectedCategory != 'all') {
      return AppColors.categoryColor(selectedCategory);
    }
    if (options.isEmpty) {
      return AppColors.canvas;
    }
    return AppColors.categoryColor(
      options[currentIndex.clamp(0, options.length - 1)].category,
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: AppColors.primary,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? AppColors.primary : AppColors.muted,
              decoration:
                  selected ? TextDecoration.underline : TextDecoration.none,
              decorationColor: AppColors.primary,
            ),
      ),
    );
  }
}

class _ResetPage extends StatelessWidget {
  const _ResetPage({
    required this.option,
    required this.onTap,
  });

  final ResetOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const Spacer(flex: 3),
          Text(
            option.category.toUpperCase(),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.terracotta,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            option.title,
            style: textTheme.displayMedium?.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            option.subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primary.withOpacity(0.72),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(
              'begin',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            option.duration,
            style: textTheme.bodySmall?.copyWith(color: AppColors.placeholder),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
