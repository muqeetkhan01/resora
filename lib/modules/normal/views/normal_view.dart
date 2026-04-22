import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/normal_controller.dart';

class NormalView extends GetView<NormalController> {
  const NormalView({super.key});

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
              const CenteredBackHeader(title: 'is this normal'),
              const SizedBox(height: AppSpacing.lg),
              _CategoryTabs(controller: controller),
              const SizedBox(height: AppSpacing.md),
              Obx(
                () => Row(
                  children: [
                    _SortChip(
                      label: 'most felt',
                      selected: controller.sortMode.value == 'felt',
                      onTap: () => controller.setSortMode('felt'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _SortChip(
                      label: 'latest',
                      selected: controller.sortMode.value == 'latest',
                      onTap: () => controller.setSortMode('latest'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.openAskQuestion,
                      child: Text(
                        'ask anonymously',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Obx(() {
                  final topics = controller.topics;
                  if (topics.isEmpty) {
                    return Center(
                      child: Text(
                        'No topics yet for this category.',
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: topics.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final topic = topics[index];

                      return InkWell(
                        onTap: () => _openTopicSheet(context, topic),
                        child: _TopicCard(
                          topic: topic,
                          categoryLabel:
                              controller.categoryLabel(topic.tab).toUpperCase(),
                          voicesCount: controller.voicesFor(topic).length,
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTopicSheet(BuildContext context, NormalTopicItem topic) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TopicSheet(topic: topic, controller: controller),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.controller});

  final NormalController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = controller.selectedCategory.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = selected == category;

            return TextButton(
              onPressed: () => controller.selectCategory(category),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                controller.categoryLabel(category).toLowerCase(),
                style: textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.placeholder,
                  decoration: isSelected
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color:
                selected ? AppColors.primary.withOpacity(0.3) : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? AppColors.primary : AppColors.placeholder,
                letterSpacing: 0.7,
              ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.categoryLabel,
    required this.voicesCount,
  });

  final NormalTopicItem topic;
  final String categoryLabel;
  final int voicesCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryLabel,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.terracotta,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '"${topic.question}"',
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.warmDark,
              height: 1.45,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${topic.metoo} felt this',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
              Text(
                voicesCount == 0
                    ? 'be the first voice'
                    : '$voicesCount voice${voicesCount == 1 ? '' : 's'}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicSheet extends StatefulWidget {
  const _TopicSheet({
    required this.topic,
    required this.controller,
  });

  final NormalTopicItem topic;
  final NormalController controller;

  @override
  State<_TopicSheet> createState() => _TopicSheetState();
}

class _TopicSheetState extends State<_TopicSheet> {
  final _voiceController = TextEditingController();

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 3,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                color: AppColors.line,
              ),
            ),
            Text(
              widget.controller.categoryLabel(widget.topic.tab).toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${widget.topic.question}"',
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.warmDark,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${widget.topic.metoo} people felt this too',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPERT ANSWER · ${widget.topic.expertByline}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.topic.expertAnswer,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.warmDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (widget.controller.voicesFor(widget.topic).isNotEmpty) ...[
              Text(
                'COMMUNITY VOICES',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.placeholder,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...widget.controller.voicesFor(widget.topic).map(
                    (voice) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        '"$voice"',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.placeholder,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(
              controller: _voiceController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'add your voice (anonymous)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  widget.controller.addVoiceFor(
                    topic: widget.topic,
                    voice: _voiceController.text,
                  );
                  Navigator.of(context).pop();
                },
                child: Text(
                  'submit voice',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
