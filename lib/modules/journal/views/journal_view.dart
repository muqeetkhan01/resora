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
                          onWriteOwn: () =>
                              controller.openEditor(prompt: prompt),
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
                          () => _ThinPageSlider(
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

class _PromptPage extends StatelessWidget {
  const _PromptPage({
    required this.prompt,
    required this.onWriteOwn,
    required this.onStartWriting,
  });

  final String prompt;
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
        const Spacer(),
      ],
    );
  }
}
