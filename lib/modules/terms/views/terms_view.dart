import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'key terms'),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                decoration: const InputDecoration(hintText: 'Search key terms'),
              ),
              const SizedBox(height: AppSpacing.lg),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: alphabet
                      .map(
                        (letter) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: Text(
                            letter,
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Obx(
                () {
                  final terms = controller.terms;
                  if (terms.isEmpty) {
                    return Text(
                      'No key terms published yet.',
                      style: textTheme.bodyMedium,
                    );
                  }

                  return Column(
                    children: terms
                        .map(
                          (term) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(term.term, style: textTheme.titleLarge),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  term.definition,
                                  style: textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.primary),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Divider(height: 1),
                              ],
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
      ),
    );
  }
}
