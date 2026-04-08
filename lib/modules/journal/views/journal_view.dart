import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../../../widgets/link_action_row.dart';
import '../../../widgets/snap_feed_indicator.dart';
import '../controllers/journal_controller.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          final selectedCategory = controller.selectedCategory.value;
          final currentIndex = controller.currentPage.value;
          final prompts = controller.prompts;
          final backgroundColor = _backgroundColorFor(
            selectedCategory: selectedCategory,
            currentIndex: currentIndex,
            prompts: prompts,
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
                    const CenteredBackHeader(title: 'journal'),
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
                            itemCount: prompts.length,
                            itemBuilder: (context, index) {
                              final prompt = prompts[index];

                              return _PromptPage(
                                prompt: prompt,
                                onWriteOwn: () => controller.openEditor(
                                    prompt: prompt.prompt),
                                onStartWriting: () => controller.openEditor(
                                    prompt: prompt.prompt),
                              );
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: SnapFeedIndicator(
                                count: prompts.length,
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
    required List<JournalPrompt> prompts,
  }) {
    if (selectedCategory != 'all') {
      return AppColors.categoryColor(selectedCategory);
    }
    if (prompts.isEmpty) {
      return AppColors.canvas;
    }
    return AppColors.categoryColor(
      prompts[currentIndex.clamp(0, prompts.length - 1)].category,
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

class _PromptPage extends StatelessWidget {
  const _PromptPage({
    required this.prompt,
    required this.onWriteOwn,
    required this.onStartWriting,
  });

  final JournalPrompt prompt;
  final VoidCallback onWriteOwn;
  final VoidCallback onStartWriting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            prompt.category.toUpperCase(),
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.terracotta,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            prompt.prompt,
            style: textTheme.displayMedium?.copyWith(fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          LinkActionRow(
            label: 'write your own',
            color: AppColors.primary,
            iconColor: AppColors.terracotta,
            iconSize: 14,
            alignStart: false,
            onTap: onWriteOwn,
          ),
          const SizedBox(height: AppSpacing.xs),
          LinkActionRow(
            label: 'start writing',
            color: AppColors.primary,
            iconColor: AppColors.terracotta,
            iconSize: 14,
            alignStart: false,
            onTap: onStartWriting,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
