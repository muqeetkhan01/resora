import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/qa_controller.dart';

class QaView extends GetView<QaController> {
  const QaView({super.key});

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
              Text('q&a', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Expert-written answers for parenting, emotions, work stress, and regulation.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller.searchController,
                onChanged: controller.setQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(AppIcons.search),
                  hintText: 'Search questions',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: controller.categories
                      .map(
                        (category) => AppTagChip(
                          label: category,
                          selected: controller.selectedCategory.value == category,
                          onTap: () => controller.selectCategory(category),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need a custom answer?', style: textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Try Help Me Now for in the moment guidance.',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppButton(
                      label: 'Open chat',
                      onPressed: () => Get.toNamed(AppRoutes.chat),
                      expanded: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(() {
                if (controller.filtered.isEmpty) {
                  return _EmptyQaState(
                    onTap: () => Get.toNamed(AppRoutes.chat),
                  );
                }

                return Column(
                  children: List.generate(controller.filtered.length, (index) {
                    final item = controller.filtered[index];
                    final expanded = controller.expandedIndex.value == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _QaCard(
                        item: item,
                        expanded: expanded,
                        onTap: () => controller.toggleExpanded(index),
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _QaCard extends StatelessWidget {
  const _QaCard({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final QaItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
            Row(
              children: [
                Expanded(child: Text(item.question, style: textTheme.titleLarge)),
                Icon(
                  expanded ? Icons.remove_rounded : Icons.add_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(item.category, style: textTheme.bodySmall),
            if (expanded) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                item.answer,
                style: textTheme.bodyMedium?.copyWith(
                  color: item.isPremium ? AppColors.muted : AppColors.warmDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (item.isPremium)
                const AppButton(
                  label: 'Unlock expert answers',
                  onPressed: null,
                  expanded: false,
                )
              else
                const AppButton(
                  label: 'Related space',
                  style: AppButtonStyle.secondary,
                  onPressed: null,
                  expanded: false,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyQaState extends StatelessWidget {
  const _EmptyQaState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.questions, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('We’ll add this soon.', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try Help Me Now for now.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Open chat', onPressed: onTap, expanded: false),
        ],
      ),
    );
  }
}
