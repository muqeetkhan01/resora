import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/resets_controller.dart';

class ResetsView extends GetView<ResetsController> {
  const ResetsView({super.key});

  static const Map<String, String> _categoryDescriptions = {
    'all': 'Every prompt in this section',
    'ground': 'Overwhelm, chaos, cannot think',
    'release': 'Tension, heaviness, letting go',
    'clarity': 'Foggy, indecisive, need to think',
    'connect': 'Loneliness, feeling unseen',
    'restore': 'Exhaustion, need to refill',
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.terracotta,
                ),
              ),
            );
          }

          final options = controller.filteredOptions;
          if (options.isEmpty) {
            return const _EditorialEmptyState(
              title: 'gentle reset',
              message: 'No reset sessions published yet.',
            );
          }

          final maxIndex = options.length - 1;
          final index = controller.currentPage.value.clamp(0, maxIndex);
          if (index != controller.currentPage.value) {
            controller.setCurrentPage(index);
          }
          final option = options[index];
          final titleSize = _titleSizeFor(option.title);
          final selected = controller.selectedCategory.value;
          final hasPrevious = index > 0;
          final hasNext = index < maxIndex;

          return Stack(
            children: [
              const _EditorialBackground(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: Get.back,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 28, height: 28),
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 15,
                            color: AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'gentle reset',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.58),
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (selected != 'all')
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: _ActiveFilterChip(
                          label: selected,
                          onClear: () => controller.selectCategory('all'),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.terracotta.withOpacity(0.7),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                option.category.toUpperCase(),
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.terracotta.withOpacity(0.9),
                                  letterSpacing: 3.2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                option.title,
                                style: textTheme.displayLarge?.copyWith(
                                  color: AppColors.white,
                                  fontSize: titleSize,
                                  height: 1.04,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Container(
                                width: 28,
                                height: 0.8,
                                color: AppColors.white.withOpacity(0.22),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                option.subtitle,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white.withOpacity(0.56),
                                  height: 1.75,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _BottomBar(
                      durationLabel: option.duration,
                      beginLabel: 'begin',
                      onBegin: () => controller.openReset(option),
                      onFilter: () async {
                        final selectedCategory =
                            await _showCategorySheet(context, selected);
                        if (selectedCategory != null) {
                          controller.selectCategory(selectedCategory);
                        }
                      },
                      onPrevious: hasPrevious
                          ? () => controller.setCurrentPage(index - 1)
                          : null,
                      onNext: hasNext
                          ? () => controller.setCurrentPage(index + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<String?> _showCategorySheet(
    BuildContext context,
    String selected,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.canvas,
      useSafeArea: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 32,
              height: 3,
              color: AppColors.primary.withOpacity(0.18),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final category in controller.categories)
              InkWell(
                onTap: () => Navigator.of(context).pop(category),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: selected == category
                                        ? AppColors.primary
                                        : AppColors.primary.withOpacity(0.72),
                                    fontSize: 24,
                                    fontStyle: FontStyle.normal,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              _categoryDescriptions[category] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.placeholder,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (selected == category)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.terracotta,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        );
      },
    );
  }

  double _titleSizeFor(String value) {
    final length = value.trim().length;
    if (length > 90) return 30;
    if (length > 70) return 33;
    if (length > 52) return 36;
    if (length > 38) return 40;
    return 44;
  }
}

class _EditorialBackground extends StatelessWidget {
  const _EditorialBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.primary),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(width: 2, color: AppColors.white.withOpacity(0.14)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.7),
                radius: 1.1,
                colors: [
                  AppColors.white.withOpacity(0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditorialEmptyState extends StatelessWidget {
  const _EditorialEmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _EditorialBackground(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.white,
                        fontSize: 42,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onClear,
  });

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white.withOpacity(0.2)),
        color: AppColors.white.withOpacity(0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.64),
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.white.withOpacity(0.44),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.durationLabel,
    required this.beginLabel,
    required this.onBegin,
    required this.onFilter,
    required this.onPrevious,
    required this.onNext,
  });

  final String durationLabel;
  final String beginLabel;
  final VoidCallback onBegin;
  final VoidCallback onFilter;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.white.withOpacity(0.12)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          Text(
            durationLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.3),
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(width: AppSpacing.lg),
          TextButton(
            onPressed: onBegin,
            child: Text(
              beginLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.86),
                    letterSpacing: 2.3,
                  ),
            ),
          ),
          const Spacer(),
          _SquareButton(
            icon: Icons.tune_rounded,
            onTap: onFilter,
          ),
          const SizedBox(width: AppSpacing.xs),
          _SquareButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: onPrevious,
          ),
          const SizedBox(width: AppSpacing.xs),
          _SquareButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.white.withOpacity(disabled ? 0.08 : 0.24),
          ),
          color:
              disabled ? Colors.transparent : AppColors.white.withOpacity(0.05),
        ),
        child: Icon(
          icon,
          color: AppColors.white.withOpacity(disabled ? 0.26 : 0.75),
          size: 21,
        ),
      ),
    );
  }
}
