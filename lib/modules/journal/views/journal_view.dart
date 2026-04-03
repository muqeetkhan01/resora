import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/link_action_row.dart';
import '../../../widgets/snap_feed_indicator.dart';
import '../controllers/journal_controller.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

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
              SizedBox(
                height: 34,
                child: Obx(
                  () {
                    final selectedMode = controller.selectedMode.value;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.modes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final selected = selectedMode == index;

                        return TextButton(
                          onPressed: () => controller.selectMode(index),
                          child: Text(
                            controller.modes[index],
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
                child: Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      onPageChanged: controller.setCurrentPage,
                      itemCount: controller.prompts.length,
                      itemBuilder: (context, index) {
                        final prompt = controller.prompts[index];

                        return _PromptPage(
                          prompt: prompt,
                          index: index + 1,
                          count: controller.prompts.length,
                          onWriteOwn: () => controller.openEditor(prompt: prompt),
                          onStartWriting: () =>
                              controller.openEditor(prompt: prompt),
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Obx(
                          () => SnapFeedIndicator(
                            count: controller.prompts.length,
                            currentIndex: controller.currentPage.value,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptPage extends StatelessWidget {
  const _PromptPage({
    required this.prompt,
    required this.index,
    required this.count,
    required this.onWriteOwn,
    required this.onStartWriting,
  });

  final String prompt;
  final int index;
  final int count;
  final VoidCallback onWriteOwn;
  final VoidCallback onStartWriting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          prompt,
          style: textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        LinkActionRow(
            label: 'write your own', alignStart: false, onTap: onWriteOwn),
        const SizedBox(height: AppSpacing.xs),
        LinkActionRow(
            label: 'start writing', alignStart: false, onTap: onStartWriting),
        const SizedBox(height: AppSpacing.xl),
        Text(
          '$index / $count',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const Spacer(),
      ],
    );
  }
}
