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
      backgroundColor: AppColors.canvas,
      body: SafeArea(
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
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('gentle reset', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Regulate first. Reflect later.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 36,
                child: Obx(
                  () {
                    final selectedCategory = controller.selectedCategory.value;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final selected = selectedCategory == category;

                        return TextButton(
                          onPressed: () => controller.selectCategory(category),
                          child: Text(
                            category,
                            style: textTheme.bodySmall?.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.muted,
                              decoration: selected
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(
                  () {
                    final options = controller.filteredOptions;

                    return Stack(
                      children: [
                        PageView.builder(
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
                              currentIndex: controller.currentPage.value,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
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

    return Column(
      children: [
        const Spacer(flex: 3),
        Text(
          option.title,
          style: textTheme.displayMedium?.copyWith(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          option.subtitle,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(option.duration, style: textTheme.bodySmall),
        const Spacer(flex: 4),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                AppIcons.forward,
                size: 18,
                color: AppColors.terracotta,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
