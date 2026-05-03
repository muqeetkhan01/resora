import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../controllers/normal_controller.dart';

class NormalView extends GetView<NormalController> {
  const NormalView({super.key});

  static const _thumbPool = [
    AppAssets.homeNormalStem,
    AppAssets.homeComingSoonFlower,
    AppAssets.spaceRoom,
    AppAssets.spaceGarden,
    AppAssets.spaceMountain,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            const _NormalHero(),
            SizedBox(
              height: 40,
              child: Obx(() {
                final selected = controller.selectedCategory.value;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: controller.categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected = selected == category;

                    return InkWell(
                      onTap: () => controller.selectCategory(category),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          controller.categoryLabel(category).toLowerCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.placeholder,
                                    decoration: isSelected
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Obx(
                () => Row(
                  children: [
                    _SortButton(
                      label: 'most felt',
                      selected: controller.sortMode.value == 'felt',
                      onTap: () => controller.setSortMode('felt'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _SortButton(
                      label: 'latest',
                      selected: controller.sortMode.value == 'latest',
                      onTap: () => controller.setSortMode('latest'),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: controller.openAskQuestion,
                      child: Text(
                        'ask anonymously',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 1.1,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.line),
            Expanded(
              child: Obx(() {
                final topics = controller.topics;
                if (topics.isEmpty) {
                  return Center(
                    child: Text(
                      'No topics yet for this category.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return InkWell(
                      onTap: () => _openTopicSheet(context, topic),
                      child: _TopicCard(
                        topic: topic,
                        imagePath: _thumbPool[index % _thumbPool.length],
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
    );
  }

  Future<void> _openTopicSheet(BuildContext context, NormalTopicItem topic) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TopicSheet(topic: topic, controller: controller),
    );
  }
}

class _NormalHero extends StatelessWidget {
  const _NormalHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.asset(
            AppAssets.homeComingSoonFlower,
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.4),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.36),
                  Colors.black.withOpacity(0.48),
                ],
              ),
            ),
          ),
        ),
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
                'is this normal',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.white,
                      fontSize: 34,
                      fontStyle: FontStyle.normal,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You are not alone in this',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withOpacity(0.68),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
          color: selected ? AppColors.primary : Colors.transparent,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? AppColors.white : AppColors.placeholder,
                letterSpacing: 0.9,
              ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.imagePath,
    required this.categoryLabel,
    required this.voicesCount,
  });

  final NormalTopicItem topic;
  final String imagePath;
  final String categoryLabel;
  final int voicesCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRect(
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.terracotta,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '"${topic.question}"',
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.primary.withOpacity(0.85),
                    height: 1.3,
                    fontStyle: FontStyle.normal,
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
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"${widget.topic.question}"',
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.warmDark,
                fontSize: 40,
                fontStyle: FontStyle.normal,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${widget.topic.metoo} people felt this too',
              style:
                  textTheme.bodySmall?.copyWith(color: AppColors.placeholder),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              padding: const EdgeInsets.only(left: AppSpacing.md),
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
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        '"$voice"',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.placeholder,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.sm),
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
                onPressed: () async {
                  final saved = await widget.controller.addVoiceFor(
                    topic: widget.topic,
                    voice: _voiceController.text,
                  );
                  if (saved && context.mounted) {
                    Navigator.of(context).pop();
                  }
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
