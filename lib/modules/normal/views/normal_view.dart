import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/normal_controller.dart';

class NormalView extends GetView<NormalController> {
  const NormalView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.close, color: AppColors.primary),
              ),
              Text('is this normal?', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Short, steady answers for the thing you are trying to make sense of.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search a question',
                  prefixIcon: Icon(AppIcons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(
                () => Column(
                  children: controller.topics
                      .map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _NormalTopicCard(topic: topic),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NormalTopicCard extends GetView<NormalController> {
  const _NormalTopicCard({required this.topic});

  final QaItem topic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic.question, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            topic.answer,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.warmDark),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppButton(
                label: 'Related reset',
                style: AppButtonStyle.secondary,
                onPressed: controller.openRelatedReset,
                expanded: false,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Explore in journal',
                style: AppButtonStyle.ghost,
                onPressed: controller.openJournal,
                expanded: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
