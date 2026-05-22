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
  int _tabIndex = 0;

  static const _tabs = <String>[
    'all',
    'ground',
    'release',
    'clarity',
    'connect',
    'restore',
  ];

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
                      'key terms',
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
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final selected = index == _tabIndex;
                    return InkWell(
                      onTap: () => setState(() => _tabIndex = index),
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
                          _tabs[index],
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
                      itemCount: terms.length,
                      onPageChanged: (value) => setState(() => _active = value),
                      itemBuilder: (context, index) {
                        final item = terms[index];
                        return _TermSlide(
                          item: item,
                          onReadDefinition: () => _openDefinitionSheet(
                            context,
                            title: item.term.toString(),
                            definition: item.definition.toString(),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: _VerticalProgress(
                          total: terms.length,
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

  Future<void> _openDefinitionSheet(
    BuildContext context, {
    required String title,
    required String definition,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
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
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFF4A342B),
                    fontStyle: FontStyle.normal,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              definition,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0x804A342B),
                    height: 1.7,
                  ),
            ),
            const SizedBox(height: 12),
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

class _TermSlide extends StatelessWidget {
  const _TermSlide({
    required this.item,
    required this.onReadDefinition,
  });

  final dynamic item;
  final VoidCallback onReadDefinition;

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
              Text(
                'GROUND',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item.term.toString(),
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  color: const Color(0xFF3B2C24),
                  height: 1.2,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 20),
              Container(width: 32, height: 1, color: const Color(0xFFE6E6E6)),
              const SizedBox(height: 20),
              Text(
                _previewDefinition(item.definition.toString()),
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA3A3A3),
                  height: 1.6,
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: onReadDefinition,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.terracotta,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'READ DEFINITION',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.terracotta,
                      letterSpacing: 1.5,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _previewDefinition(String definition) {
    final text = definition.trim();
    if (text.isEmpty) {
      return text;
    }
    final firstDot = text.indexOf('.');
    if (firstDot == -1 || firstDot == text.length - 1) {
      return text;
    }
    return text.substring(0, firstDot + 1);
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
