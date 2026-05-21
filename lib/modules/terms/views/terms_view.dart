import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../controllers/terms_controller.dart';

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
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
    final controller = Get.find<TermsController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF9),
      body: SafeArea(
        child: Obx(() {
          final terms = controller.terms;
          if (terms.isEmpty) {
            return Center(
              child: Text(
                'No key terms published yet.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= terms.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final currentNumber = (_active + 1).toString().padLeft(2, '0');
          final totalNumber = terms.length.toString().padLeft(2, '0');

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
                      'key terms',
                      style: textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        color: const Color(0xFF4A342B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$currentNumber / $totalNumber',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0x804A342B),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search key terms',
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: terms.length,
                      onPageChanged: (value) => setState(() => _active = value),
                      itemBuilder: (context, index) {
                        final item = terms[index];
                        return _TermSlide(item: item);
                      },
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 14,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            terms.length,
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
                child: TextButton(
                  onPressed: () {
                    controller.searchController.clear();
                    controller.onSearch('');
                  },
                  child: Text(
                    'SHOW ALL TERMS',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.terracotta,
                      decoration: TextDecoration.underline,
                      letterSpacing: 1.7,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TermSlide extends StatelessWidget {
  const _TermSlide({required this.item});

  final dynamic item;

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
              const SizedBox(height: 18),
              Text(
                item.term.toString(),
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  color: const Color(0xFF4A342B),
                  height: 1.1,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 14),
              Container(width: 28, height: 0.5, color: const Color(0x334A342B)),
              const SizedBox(height: 14),
              Text(
                item.definition.toString(),
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0x804A342B),
                  height: 1.65,
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
