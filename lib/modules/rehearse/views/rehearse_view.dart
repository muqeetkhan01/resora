import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../theme/app_colors.dart';
import '../controllers/rehearse_controller.dart';

class RehearseView extends StatefulWidget {
  const RehearseView({super.key});

  @override
  State<RehearseView> createState() => _RehearseViewState();
}

class _RehearseViewState extends State<RehearseView> {
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
    final controller = Get.find<RehearseController>();
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

          final scenarios = controller.filteredScenarios;
          if (scenarios.isEmpty) {
            return Center(
              child: Text(
                'No rehearsal scenarios published yet.',
                style: textTheme.bodyMedium,
              ),
            );
          }

          if (_active >= scenarios.length) {
            _active = 0;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) _pageController.jumpToPage(0);
            });
          }

          final categories = controller.categories;
          final selectedCategory = controller.selectedCategory.value;
          final current = scenarios[_active];
          final currentNumber = (_active + 1).toString().padLeft(2, '0');
          final totalNumber = scenarios.length.toString().padLeft(2, '0');

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
                      'rehearse the moment',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFFA3A3A3),
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
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
                      itemCount: scenarios.length,
                      onPageChanged: (value) {
                        setState(() => _active = value);
                        controller.setCurrentPage(value);
                      },
                      itemBuilder: (context, index) {
                        final scenario = scenarios[index];
                        return _ScenarioSlide(scenario: scenario);
                      },
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: _VerticalProgress(
                          total: scenarios.length,
                          active: _active,
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
                      '2 min',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0x80A3A3A3),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 24),
                    TextButton(
                      onPressed: () => controller.openScenario(current),
                      child: Text(
                        'BEGIN SESSION',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.terracotta,
                          letterSpacing: 2,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.terracotta,
                          decorationThickness: 1,
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
      BuildContext context, RehearseController controller) async {
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

class _ScenarioSlide extends StatelessWidget {
  const _ScenarioSlide({required this.scenario});

  final dynamic scenario;

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
                scenario.category.toString().toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.terracotta,
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                scenario.title.toString(),
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  color: const Color(0xFF3B2C24),
                  height: 1.2,
                  fontStyle: FontStyle.normal,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 32,
                height: 1,
                color: const Color(0xFFE6E6E6),
              ),
              const SizedBox(height: 16),
              Text(
                scenario.reframe.toString(),
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
