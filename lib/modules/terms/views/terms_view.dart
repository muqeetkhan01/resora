import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../controllers/terms_controller.dart';

class TermsView extends GetView<TermsController> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const _TermsHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search key terms',
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: Obx(
                () {
                  final terms = controller.terms;
                  if (terms.isEmpty) {
                    return Center(
                      child: Text(
                        'No key terms published yet.',
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: terms.length,
                    itemBuilder: (context, index) {
                      final item = terms[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.line),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.term,
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.definition,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.placeholder,
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsHero extends StatelessWidget {
  const _TermsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'key terms',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 34,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Plain language definitions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withOpacity(0.66),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
