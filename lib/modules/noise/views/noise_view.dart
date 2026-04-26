import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/noise_controller.dart';

class NoiseView extends GetView<NoiseController> {
  const NoiseView({super.key});

  static const _thumbPool = [
    AppAssets.spaceGarden,
    AppAssets.spaceMountain,
    AppAssets.spaceRoom,
    AppAssets.homeNormalStem,
    AppAssets.homeComingSoonFlower,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => _NoiseHero(trackCount: controller.totalTrackCount)),
            SizedBox(
              height: 44,
              child: Obx(() {
                final selected = controller.selectedCategory.value;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected = selected == category;
                    return InkWell(
                      onTap: () => controller.selectCategory(category),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          category.toLowerCase(),
                          style: textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.placeholder,
                            decoration: isSelected
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: Obx(() {
                final tracks = controller.tracks;
                if (tracks.isEmpty) {
                  return Center(
                    child: Text(
                      'No audio tracks published yet.',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _NoiseTrackRow(
                      track: track,
                      imagePath: _thumbPool[index % _thumbPool.length],
                      onTap: () => controller.openTrack(track),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoiseHero extends StatelessWidget {
  const _NoiseHero({required this.trackCount});

  final int trackCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'quiet the noise',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 34,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$trackCount tracks · nature & visualizations',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.65),
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoiseTrackRow extends StatelessWidget {
  const _NoiseTrackRow({
    required this.track,
    required this.imagePath,
    required this.onTap,
  });

  final AudioTrack track;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.categoryColor(track.category);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.line),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 58,
              color: categoryColor.withOpacity(0.8),
            ),
            const SizedBox(width: AppSpacing.sm),
            ClipRect(
              child: SizedBox(
                width: 58,
                height: 58,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      track.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.placeholder,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.terracotta),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.terracotta,
                    size: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  track.duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.placeholder,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
