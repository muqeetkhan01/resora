import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/link_action_row.dart';
import '../../../widgets/snap_feed_indicator.dart';
import '../controllers/rehearse_controller.dart';

class RehearseView extends GetView<RehearseController> {
  const RehearseView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
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
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('rehearse the moment', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A reframe, a script, and a steadier next line.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 36,
                child: Obx(
                  () {
                    final selectedCategory = controller.selectedCategory.value;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final selected = selectedCategory == category;

                        return TextButton(
                          onPressed: () => controller.selectCategory(category),
                          child: Text(
                            category,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  selected ? AppColors.primary : AppColors.muted,
                              decoration: selected
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(
                  () {
                    final scenarios = controller.filteredScenarios;

                    return Stack(
                      children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          onPageChanged: controller.setCurrentPage,
                          itemCount: scenarios.length,
                          itemBuilder: (context, index) {
                            final scenario = scenarios[index];
                            return _ScenarioPage(
                              scenario: scenario,
                              index: index + 1,
                              count: scenarios.length,
                              onTap: () => controller.openScenario(scenario),
                            );
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: SnapFeedIndicator(
                              count: scenarios.length,
                              currentIndex: controller.currentPage.value,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioPage extends StatelessWidget {
  const _ScenarioPage({
    required this.scenario,
    required this.index,
    required this.count,
    required this.onTap,
  });

  final RehearsalScenario scenario;
  final int index;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(scenario.title, style: textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.md),
        Text(
          scenario.reframe,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
        ),
        const Spacer(),
        Text('$index / $count', style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        LinkActionRow(label: 'open prompt', onTap: onTap),
      ],
    );
  }
}
