import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/community_controller.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(AppIcons.close, color: AppColors.primary),
            ),
            Text('community', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A softer preview of peer support and shared perspective.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Keep this light. Take what helps. Leave the rest.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.white),
                  ),
                ],
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
              () {
                final posts = controller.posts;
                if (posts.isEmpty) {
                  return Text(
                    'No community posts published yet.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.placeholder,
                    ),
                  );
                }

                return Column(
                  children: posts
                      .map(
                        (post) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.surface,
                                      child: Text(
                                        post.author.characters.first,
                                        style: textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(post.author,
                                              style: textTheme.titleMedium),
                                          Text(post.role,
                                              style: textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(post.title, style: textTheme.titleLarge),
                                const SizedBox(height: AppSpacing.sm),
                                Text(post.preview, style: textTheme.bodyMedium),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Text(post.category, style: textTheme.bodySmall),
                                    const Spacer(),
                                    const Icon(Icons.favorite_border_rounded,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text('${post.likes}',
                                        style: textTheme.bodySmall),
                                    const SizedBox(width: AppSpacing.md),
                                    const Icon(Icons.mode_comment_outlined,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text('${post.comments}',
                                        style: textTheme.bodySmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
