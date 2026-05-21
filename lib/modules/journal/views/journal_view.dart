import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/journal_controller.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
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
    final controller = Get.find<JournalController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
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
          final prompt = prompts[_active];
          final currentNumber = (_active + 1).toString().padLeft(2, '0');
          final totalNumber = prompts.length.toString().padLeft(2, '0');

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 28, height: 28),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 15,
                        color: AppColors.terracotta,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'journal',
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        color: const Color(0xFF4A342B),
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.openHistory,
                      child: Text(
                        'history',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                        ),
                      ),
                    ),
                    Text(
                      '$currentNumber / $totalNumber',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0x804A342B),
                        letterSpacing: 0.4,
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
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
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
                          category,
                          style: textTheme.bodySmall?.copyWith(
                            color: selected
                                ? const Color(0xFF4A342B)
                                : const Color(0xFFA89890),
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
                      itemCount: prompts.length,
                      onPageChanged: (value) {
                        setState(() => _active = value);
                        controller.setCurrentPage(value);
                      },
                      itemBuilder: (context, index) =>
                          _JournalSlide(prompt: prompts[index]),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 14,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            prompts.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 1,
                              height: index == _active ? 58 : 5,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              color: index == _active
                                  ? AppColors.terracotta
                                  : const Color(0x2E4A342B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => controller.openEditor(prompt: ''),
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
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          controller.openEditor(prompt: prompt.prompt),
                      child: Text(
                        'BEGIN JOURNAL',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 1.8,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.terracotta,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showCategorySheet(context, controller),
                      icon: const Icon(
                        AppIcons.filter,
                        size: 18,
                        color: AppColors.terracotta,
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

  Future<void> _showCategorySheet(
      BuildContext context, JournalController controller) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFFAFBF9),
      useSafeArea: true,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(width: 34, height: 3, color: AppColors.line),
          const SizedBox(height: 10),
          for (final category in controller.categories)
            ListTile(
              title: Text(category),
              onTap: () => Navigator.of(context).pop(category),
            ),
        ],
      ),
    );
    if (selected == null) return;
    controller.selectCategory(selected);
    _active = 0;
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    if (mounted) setState(() {});
  }
}

class _JournalSlide extends StatelessWidget {
  const _JournalSlide({required this.prompt});

  final JournalPrompt prompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 42, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 1.5,
                  height: 50,
                  color: AppColors.terracotta.withOpacity(0.7)),
              const SizedBox(height: 14),
              Text(
                prompt.category.toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                prompt.prompt,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  color: const Color(0xFF4A342B),
                  height: 1.1,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
