import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';

class JournalEditorView extends StatefulWidget {
  const JournalEditorView({super.key});

  @override
  State<JournalEditorView> createState() => _JournalEditorViewState();
}

class _JournalEditorViewState extends State<JournalEditorView> {
  late final TextEditingController _controller;
  late final String _title;
  late final String _subtitle;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;

    if (argument is JournalEntry) {
      _title = argument.title;
      _subtitle = '${argument.date} • ${argument.wordCount} words';
      _controller = TextEditingController(text: argument.preview);
    } else {
      _title = 'New entry';
      _subtitle = 'Auto-save on';
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(AppIcons.close, color: AppColors.primary),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_title, style: textTheme.displayMedium),
                      const SizedBox(height: 2),
                      Text(_subtitle, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '${_controller.text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length} words',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              'Prompt: What helped more than I expected today?',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                expands: true,
                style: textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Write what is true right now.',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Done',
                  onPressed: Get.back,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'AI reflection',
                  style: AppButtonStyle.secondary,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
