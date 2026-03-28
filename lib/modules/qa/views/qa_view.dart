import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/qa_controller.dart';

class QaView extends GetView<QaController> {
  const QaView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.premium),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        label: const Text('Ask a question'),
        icon: const Icon(Icons.edit_outlined),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Text('Q&A', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Parenting and wellness answers with room for nuance.',
                style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: controller.searchController,
              onChanged: controller.setQuery,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search questions',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: BorderSide.none,
                ),
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
            Obx(
              () => Column(
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
              ),
            ),
          ],
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
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(item.question,
                      style: Theme.of(context).textTheme.titleLarge)),
              Icon(expanded ? Icons.remove_rounded : Icons.add_rounded),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.category, style: Theme.of(context).textTheme.bodySmall),
          if (expanded) ...[
            const SizedBox(height: AppSpacing.md),
            if (item.isPremium) ...[
              Text(
                'Premium answer preview',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(item.answer, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              const AppButton(
                label: 'Unlock expert answers',
                onPressed: null,
              ),
            ] else
              Text(item.answer, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
