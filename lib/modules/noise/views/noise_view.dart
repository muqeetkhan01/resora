import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/noise_controller.dart';

class NoiseView extends StatefulWidget {
  const NoiseView({super.key});

  @override
  State<NoiseView> createState() => _NoiseViewState();
}

class _NoiseViewState extends State<NoiseView> {
  late final PageController _pageController;
  int _active = 0;

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
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 28, height: 28),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 16,
                        color: Color(0xFFA3A3A3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'quiet the noise',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category == selectedCategory;
                    return InkWell(
                      onTap: () {
                        controller.selectCategory(category);
                        _active = 0;
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(0);
                        }
                        setState(() {});
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selected
                                  ? AppColors.terracotta
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          category.toLowerCase(),
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: selected
                                ? const Color(0xFF4A342B)
                                : const Color(0xFFA3A3A3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                        onPlay: () => controller.openTrack(tracks[index]),
                      ),
                    ),
                    Positioned(
                      top: 104,
                      bottom: 104,
                      right: 16,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            tracks.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 2,
                              height: 24,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: index == _active
                                  ? AppColors.terracotta
                                  : const Color(0xFFE6E6E6),
                            ),
                          ),
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
    required this.onPlay,
  });

  final AudioTrack track;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 104, 42, 12),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 2, height: 240, color: AppColors.terracotta),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          track.category.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.terracotta,
                            letterSpacing: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          track.duration,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFA3A3A3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 164),
                    Text(
                      track.title,
                      style: textTheme.displayLarge?.copyWith(
                        color: const Color(0xFF3B2C24),
                        fontSize: 40,
                        height: 1.2,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xFFE6E6E6),
                    ),
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
                    OutlinedButton.icon(
                      onPressed: onPlay,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.terracotta,
                        side: const BorderSide(color: AppColors.terracotta),
                        fixedSize: const Size(150, 48),
                        shape: const RoundedRectangleBorder(),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Play'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
