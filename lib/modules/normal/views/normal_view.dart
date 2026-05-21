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
          final current = topics[_active];
          final voices = controller.voicesFor(current).length;

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
                      'is this normal',
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        color: const Color(0xFF4A342B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.openAskQuestion,
                      child: Text(
                        'ask anonymously',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 1.2,
                          decoration: TextDecoration.underline,
                        ),
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
                          controller.categoryLabel(category),
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
                      top: 0,
                      bottom: 0,
                      right: 14,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            topics.length,
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
                    Text(
                      '${current.metoo} felt this · $voices voices',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0x804A342B),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _openTopicSheet(context, current),
                      child: Text(
                        'OPEN THREAD',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 1.8,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.terracotta,
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
                category,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"${topic.question}"',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  color: const Color(0xFF4A342B),
                  height: 1.15,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                topic.expertAnswer.toString(),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0x804A342B),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${topic.metoo} felt this · $voicesCount voices',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0x804A342B),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onOpen,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                  side: const BorderSide(color: AppColors.terracotta),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('Read more'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
