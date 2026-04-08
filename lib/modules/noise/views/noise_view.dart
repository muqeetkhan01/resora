import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
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
              const CenteredBackHeader(title: 'quiet the noise'),
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
                          contentPadding: EdgeInsets.zero,
                          title: _TrackRow(track: track),
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

class _TrackRow extends StatelessWidget {
  const _TrackRow({required this.track});

  final AudioTrack track;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              AppIcons.play,
              size: 18,
              color: AppColors.terracotta,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  track.description,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              track.duration,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
