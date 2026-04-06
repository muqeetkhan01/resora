import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/noise_controller.dart';

class NoiseView extends GetView<NoiseController> {
  const NoiseView({super.key});

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
              Text('quiet the noise', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'What would help right now?',
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
                            category.toLowerCase(),
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
                    final tracks = controller.tracks;

                    return ListView.separated(
                      itemCount: tracks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final track = tracks[index];

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                          title: Text(track.title, style: textTheme.titleLarge),
                          subtitle: Text(
                            track.description,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.terracotta,
                          ),
                          onTap: () => controller.openTrack(track),
                        );
                      },
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
