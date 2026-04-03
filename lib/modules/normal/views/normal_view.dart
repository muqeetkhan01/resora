import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/link_action_row.dart';
import '../../../widgets/snap_feed_indicator.dart';
import '../controllers/normal_controller.dart';

class NormalView extends GetView<NormalController> {
  const NormalView({super.key});

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
              Text('is this normal', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Short, steady answers for the thing you are trying to make sense of.',
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
                            category.toLowerCase(),
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
                    final topics = controller.topics;

                    return Stack(
                      children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          onPageChanged: controller.setCurrentPage,
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            return _NormalTopicPage(
                              topic: topic,
                              controller: controller,
                              index: index + 1,
                              count: topics.length,
                            );
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: SnapFeedIndicator(
                              count: topics.length,
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

class _NormalTopicPage extends StatelessWidget {
  const _NormalTopicPage({
    required this.topic,
    required this.controller,
    required this.index,
    required this.count,
  });

  final QaItem topic;
  final NormalController controller;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(topic.question, style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.lg),
          Text(
            topic.answer,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
          ),
          const Spacer(),
          Text('$index / $count', style: textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          LinkActionRow(
              label: 'related reset', onTap: controller.openRelatedReset),
          const SizedBox(height: AppSpacing.xs),
          LinkActionRow(
              label: 'explore in journal', onTap: controller.openJournal),
        ],
      ),
    );
  }
}
