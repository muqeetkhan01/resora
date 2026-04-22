import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/normal_controller.dart';

class NormalAskView extends GetView<NormalController> {
  const NormalAskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'ask anonymously'),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'What have you been wondering about yourself lately?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No judgment. No performance. Just your real question.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: TextField(
                  controller: controller.askController,
                  onChanged: controller.updateQuestionDraft,
                  autofocus: true,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                  decoration: const InputDecoration(
                    hintText: 'Type your question...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => TextButton(
                    onPressed: controller.canSubmitQuestion
                        ? controller.submitQuestion
                        : null,
                    child: Text(
                      'submit anonymously',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: controller.canSubmitQuestion
                                ? AppColors.primary
                                : AppColors.placeholder,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
