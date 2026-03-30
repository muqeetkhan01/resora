import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/terms_controller.dart';

class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const alphabet = ['A', 'C', 'E', 'R', 'S', 'W'];

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
              Text('key terms', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Plain-language definitions for the concepts that keep coming up.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search key terms',
                  prefixIcon: Icon(AppIcons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: alphabet
                      .map(
                        (letter) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(
                () => Column(
                  children: controller.terms
                      .map(
                        (term) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
                                Text(term.term, style: textTheme.titleLarge),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  term.definition,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: AppColors.warmDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
