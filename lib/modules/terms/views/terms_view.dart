import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_close_button.dart';
import '../../../widgets/expanded_category_selector.dart';
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
  int? _expandedIndex;
  bool _categoriesExpanded = false;

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
            _expandedIndex = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 0),
                child: Row(
                  children: [
                    AppCloseButton(onPressed: Get.back),
                    const Spacer(),
                    Text(
                      'Key Terms',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // const Spacer(),
                    // Text(
                    //   '$currentNumber / $totalNumber',
                    //   style: textTheme.bodyMedium?.copyWith(
                    //     fontSize: 14,
                    //     color: const Color(0xFFA3A3A3),
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ExpandedCategorySelector(
                categories: _tabs,
                selectedCategory: _tabs[_tabIndex],
                expanded: _categoriesExpanded,
                onExpandedChanged: (expanded) =>
                    setState(() => _categoriesExpanded = expanded),
                onSelect: (category) => setState(() {
                  _tabIndex = _tabs.indexOf(category);
                  _expandedIndex = null;
                  _categoriesExpanded = false;
                }),
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: terms.length,
                      onPageChanged: (value) => setState(() {
                        _active = value;
                        _expandedIndex = null;
                      }),
                      itemBuilder: (context, index) {
                        final item = terms[index];
                        return _TermSlide(
                          item: item,
                          expanded: _expandedIndex == index,
                          onToggleDefinition: () => setState(
                            () => _expandedIndex =
                                _expandedIndex == index ? null : index,
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
}

class _TermSlide extends StatelessWidget {
  const _TermSlide({
    required this.item,
    required this.expanded,
    required this.onToggleDefinition,
  });

  final dynamic item;
  final bool expanded;
  final VoidCallback onToggleDefinition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 104, 42, 12),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GROUND',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
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
                // const SizedBox(height: 20),
                // Container(width: 32, height: 1, color: const Color(0xFFE6E6E6)),
                const SizedBox(height: 24),
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
                  onTap: onToggleDefinition,
                  splashColor: Colors.transparent,
                  highlightColor: AppColors.line,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
                                expanded
                                    ? 'HIDE DEFINITION'
                                    : 'READ DEFINITION',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.terracotta,
                                  letterSpacing: 1.5,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              turns: expanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Text(
                                '›',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.terracotta,
                                  fontSize: 18,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 180),
                          crossFadeState: expanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 8),
                            child: Text(
                              item.definition.toString(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: const Color(0x804A342B),
                                height: 1.7,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
