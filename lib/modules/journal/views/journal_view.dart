import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_close_button.dart';
import '../../../widgets/expanded_category_selector.dart';
import '../controllers/journal_controller.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
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
    final controller = Get.find<JournalController>();
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

          final prompts = controller.prompts;
          if (prompts.isEmpty) {
            return Center(
              child: Text(
                'No journal prompts published yet.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= prompts.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final selectedCategory = controller.selectedCategory.value;
          final categories = controller.categories;
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
                      'Journal',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    // const Spacer(),

                    // Text(
                    //   '$currentNumber / $totalNumber',
                    //   style: textTheme.bodyMedium?.copyWith(
                    //     color: const Color(0xFFA3A3A3),
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    // ),
                  ],
                ),
              ),
              ExpandedCategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                expanded: _categoriesExpanded,
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
                      itemCount: prompts.length,
                      onPageChanged: (value) {
                        setState(() => _active = value);
                        controller.setCurrentPage(value);
                      },
                      itemBuilder: (context, index) => _JournalSlide(
                        prompt: prompts[index],
                        locked: prompts[index].isPremium && !hasPremiumAccess,
                        onWriteOwn: () => controller.openEditor(prompt: ''),
                        onStartWriting: () =>
                            controller.openPrompt(prompts[index]),
                        onOpenHistory: controller.openHistory,
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
                          total: prompts.length,
                          active: _active,
                        ),
                      ),
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
}

class _JournalSlide extends StatelessWidget {
  const _JournalSlide({
    required this.prompt,
    required this.locked,
    required this.onWriteOwn,
    required this.onStartWriting,
    required this.onOpenHistory,
    required this.onOpenFilters,
  });

  final JournalPrompt prompt;
  final bool locked;
  final VoidCallback onWriteOwn;
  final VoidCallback onStartWriting;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final actionTop = (constraints.maxHeight * 0.62).clamp(420.0, 520.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 104, 42, 12),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 320,
                    maxHeight: actionTop - 24,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt.category.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          prompt.prompt,
                          style: textTheme.displayLarge?.copyWith(
                            fontSize: 38,
                            color: const Color(0xFF3B2C24),
                            height: 1.2,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Container(
                        //   width: 32,
                        //   height: 1,
                        //   color: const Color(0xFFE6E6E6),
                        // ),
                        const SizedBox(height: 16),
                        Text(
                          'You do not need a perfect explanation.\nYou need a clear sentence.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFA3A3A3),
                            height: 1.6,
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: actionTop,
                child: _JournalActionRow(
                  locked: locked,
                  onWriteOwn: onWriteOwn,
                  onStartWriting: onStartWriting,
                  onOpenHistory: onOpenHistory,
                  onOpenFilters: onOpenFilters,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JournalActionRow extends StatelessWidget {
  const _JournalActionRow({
    required this.locked,
    required this.onWriteOwn,
    required this.onStartWriting,
    required this.onOpenHistory,
    required this.onOpenFilters,
  });

  final VoidCallback onWriteOwn;
  final bool locked;
  final VoidCallback onStartWriting;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onWriteOwn,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'WRITE YOUR OWN',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.6,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.terracotta,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onStartWriting,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locked) ...[
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.terracotta,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    'START WRITING',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.terracotta,
                      letterSpacing: 1.8,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onOpenHistory,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'HISTORY',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.8,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.terracotta,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: onOpenFilters,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: const Icon(
                AppIcons.filter,
                size: 18,
                color: AppColors.terracotta,
              ),
            ),
          ],
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
