import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resora/core/constants/app_icons.dart';

import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_close_button.dart';
import '../../../widgets/expanded_category_selector.dart';
import '../controllers/noise_controller.dart';

class NoiseView extends StatefulWidget {
  const NoiseView({super.key});

  @override
  State<NoiseView> createState() => _NoiseViewState();
}

class _NoiseViewState extends State<NoiseView> {
  late final PageController _pageController;
  int _active = 0;
  bool _categoriesExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NoiseController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.terracotta,
              ),
            );
          }

          final tracks = controller.tracks;
          if (tracks.isEmpty) {
            return Center(
              child: Text(
                'No audio tracks published yet.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= tracks.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final categories = controller.categories;
          final selectedCategory = controller.selectedCategory.value;
          final hasPremiumAccess = controller.hasPremiumAccess;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    AppCloseButton(onPressed: Get.back),
                    const Spacer(),
                    Text(
                      'Quiet the Noise',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ExpandedCategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                expanded: _categoriesExpanded,
                labelBuilder: (category) =>
                    category.capitalizeFirst ?? category,
                onExpandedChanged: (expanded) =>
                    setState(() => _categoriesExpanded = expanded),
                onSelect: (category) {
                  controller.selectCategory(category);
                  _active = 0;
                  _categoriesExpanded = false;
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }
                  setState(() {});
                },
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: tracks.length,
                      onPageChanged: (value) => setState(() => _active = value),
                      itemBuilder: (context, index) => _NoiseSlide(
                        track: tracks[index],
                        previewOnly: !hasPremiumAccess,
                        onPlay: () => controller.openTrack(tracks[index]),
                        onOpenFilters: () => setState(
                          () => _categoriesExpanded = !_categoriesExpanded,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: _VerticalProgress(
                          total: tracks.length,
                          active: _active,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }
}

class _NoiseSlide extends StatelessWidget {
  const _NoiseSlide({
    required this.track,
    required this.previewOnly,
    required this.onPlay,
    required this.onOpenFilters,
  });

  final AudioTrack track;
  final bool previewOnly;
  final VoidCallback onPlay;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 104, 42, 12),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    track.category.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Text(
                  //   track.duration,
                  //   style: textTheme.bodyMedium?.copyWith(
                  //     color: const Color(0xFFA3A3A3),
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                track.title,
                style: textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF3B2C24),
                  fontSize: 40,
                  height: 1.2,
                  fontStyle: FontStyle.normal,
                ),
              ),
              // const SizedBox(height: 24),
              // Container(
              //   width: double.infinity,
              //   height: 1,
              //   color: const Color(0xFFE6E6E6),
              // ),
              const SizedBox(height: 24),
              Text(
                track.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA3A3A3),
                  height: 1.6,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    track.duration,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0x80A3A3A3),
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: onPlay,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (previewOnly) ...[
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color: AppColors.terracotta,
                          ),
                          const SizedBox(width: 7),
                        ],
                        Text(
                          previewOnly ? 'TAP TO PREVIEW' : 'PLAY',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.terracotta,
                            letterSpacing: 2,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.terracotta,
                            decorationThickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onOpenFilters,
                    icon: const Icon(
                      AppIcons.filter,
                      size: 18,
                      color: AppColors.terracotta,
                    ),
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

class _VerticalProgress extends StatelessWidget {
  const _VerticalProgress({
    required this.total,
    required this.active,
  });

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    const maxBars = 6;
    final bars = total <= 1 ? 2 : total.clamp(2, maxBars);
    final mapped = total <= 1
        ? 0
        : ((active / (total - 1)) * (bars - 1)).round().clamp(0, bars - 1);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(bars, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == bars - 1 ? 0 : 8),
            child: Container(
              width: 2,
              height: 24,
              color: index == mapped
                  ? AppColors.terracotta
                  : const Color(0xFFE6E6E6),
            ),
          );
        }),
      ),
    );
  }
}
