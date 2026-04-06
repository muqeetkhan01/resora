import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
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
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.muted,
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
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _ScenarioPage(
                                scenario: scenario,
                                onTap: () => controller.openScenario(scenario),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 4,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _ThinPageSlider(
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

class _ThinPageSlider extends StatelessWidget {
  const _ThinPageSlider({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) {
      return const SizedBox.shrink();
    }

    const trackHeight = 56.0;
    const trackWidth = 2.0;
    final thumbHeight = (trackHeight / count).clamp(10.0, 18.0);
    final maxOffset = trackHeight - thumbHeight;
    final progress = count == 1 ? 0.0 : currentIndex / (count - 1);

    return SizedBox(
      width: 8,
      height: trackHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Positioned(
            top: maxOffset * progress.clamp(0.0, 1.0),
            child: Container(
              width: 3,
              height: thumbHeight,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.82),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioPage extends StatelessWidget {
  const _ScenarioPage({
    required this.scenario,
    required this.onTap,
  });

  final RehearsalScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const Spacer(flex: 3),
        Text(
          scenario.title,
          style: textTheme.displayMedium?.copyWith(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          scenario.reframe,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 4),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(
                AppIcons.forward,
                size: 18,
                color: AppColors.terracotta,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
