import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/normal_controller.dart';

class NormalView extends StatefulWidget {
  const NormalView({super.key});

  @override
  State<NormalView> createState() => _NormalViewState();
}

class _NormalViewState extends State<NormalView> {
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
    final controller = Get.find<NormalController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
          final topics = controller.topics;
          if (topics.isEmpty) {
            return Center(
              child: Text(
                'No topics yet for this category.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= topics.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final categories = controller.categories;
          final selectedCategory = controller.selectedCategory.value;
          final currentNumber = (_active + 1).toString().padLeft(2, '0');
          final totalNumber = topics.length.toString().padLeft(2, '0');

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
                      'is this normal',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$currentNumber / $totalNumber',
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
                          controller.categoryLabel(category),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  children: [
                    _InlineTab(
                      label: 'most felt',
                      active: controller.sortMode.value == 'felt',
                      onTap: () => controller.setSortMode('felt'),
                    ),
                    const SizedBox(width: 24),
                    _InlineTab(
                      label: 'latest',
                      active: controller.sortMode.value == 'latest',
                      onTap: () => controller.setSortMode('latest'),
                    ),
                    const Spacer(),
                    _InlineTab(
                      label: 'ASK ANONYMOUSLY',
                      active: true,
                      onTap: controller.openAskQuestion,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: topics.length,
                      onPageChanged: (value) => setState(() => _active = value),
                      itemBuilder: (context, index) => _NormalSlide(
                        topic: topics[index],
                        category: controller
                            .categoryLabel(topics[index].tab)
                            .toUpperCase(),
                        voicesCount: controller.voicesFor(topics[index]).length,
                        onOpen: () => _openTopicSheet(context, topics[index]),
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
                            topics.length,
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

  Future<void> _openTopicSheet(BuildContext context, dynamic topic) async {
    final controller = Get.find<NormalController>();
    final voices = controller.voicesFor(topic);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFFAFBF9),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 34, height: 3, color: AppColors.line),
            const SizedBox(height: 14),
            Text(
              topic.question.toString(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF4A342B),
                    fontStyle: FontStyle.normal,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              topic.expertAnswer.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0x804A342B),
                    height: 1.7,
                  ),
            ),
            const SizedBox(height: 14),
            if (voices.isNotEmpty)
              ...voices.take(3).map(
                    (voice) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $voice',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0x804A342B),
                            ),
                      ),
                    ),
                  ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NormalSlide extends StatelessWidget {
  const _NormalSlide({
    required this.topic,
    required this.category,
    required this.voicesCount,
    required this.onOpen,
  });

  final dynamic topic;
  final String category;
  final int voicesCount;
  final VoidCallback onOpen;

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
                    Text(
                      category,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.terracotta,
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '"${topic.question}"',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        color: const Color(0xFF3B2C24),
                        height: 1.2,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 32,
                      height: 1,
                      color: const Color(0xFFE6E6E6),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${topic.metoo} felt this',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFA3A3A3),
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _InlineTab(
                          label: 'READ CONTEXT',
                          active: true,
                          onTap: onOpen,
                        ),
                        const SizedBox(width: 24),
                        _InlineTab(
                          label: '$voicesCount VOICES',
                          active: false,
                          onTap: onOpen,
                        ),
                      ],
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

class _InlineTab extends StatelessWidget {
  const _InlineTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.terracotta : const Color(0xFFDCD6D2),
              width: active ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: active ? AppColors.terracotta : const Color(0xFFA3A3A3),
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }
}
