import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';

class JournalEditorView extends StatefulWidget {
  const JournalEditorView({super.key});

  @override
  State<JournalEditorView> createState() => _JournalEditorViewState();
}

class _JournalEditorViewState extends State<JournalEditorView> {
  late final TextEditingController _controller;
  late final String _prompt;

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;

    if (argument is JournalEntry) {
      _prompt = argument.prompt ?? 'What helped more than you expected today?';
      _controller = TextEditingController(text: argument.preview);
    } else if (argument is String) {
      _prompt = argument;
      _controller = TextEditingController();
    } else {
      _prompt = 'What helped more than you expected today?';
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.offNamed(AppRoutes.thatMattered),
                child: Text(
                  'done',
                  style:
                      textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _prompt,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.primary.withOpacity(0.26),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null,
              expands: true,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.primary),
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'start here',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
