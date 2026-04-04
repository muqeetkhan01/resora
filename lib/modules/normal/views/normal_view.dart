import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
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
              IconButton(
                onPressed: Get.back,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('is this normal', style: textTheme.displayLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Real questions. Real answers. Real voices.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.placeholder,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _CategoryTabs(controller: controller),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Obx(() {
                  final topic = controller.currentTopic;
                  final voices = controller.voicesFor(topic);
                  final isEditingVoice = controller.showingVoiceEditor.value;
                  final isVoiceConfirmed =
                      controller.showingVoiceConfirmation.value;
                  final voiceDraft = controller.voiceDraft.value;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: SingleChildScrollView(
                      key: ValueKey(
                        '${controller.selectedCategory.value}-${controller.currentCardIndex.value}-$isEditingVoice-$isVoiceConfirmed',
                      ),
                      child: _NormalTopicDetail(
                        topic: topic,
                        voices: voices,
                        controller: controller,
                        isEditingVoice: isEditingVoice,
                        isVoiceConfirmed: isVoiceConfirmed,
                        canSubmitVoice: voiceDraft.trim().isNotEmpty,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.controller});

  final NormalController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 38,
          child: Obx(() {
            final selectedCategory = controller.selectedCategory.value;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                final selected = selectedCategory == category;

                return InkWell(
                  onTap: () => controller.selectCategory(category),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      category,
                      style: textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.placeholder,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _NormalTopicDetail extends StatelessWidget {
  const _NormalTopicDetail({
    required this.topic,
    required this.voices,
    required this.controller,
    required this.isEditingVoice,
    required this.isVoiceConfirmed,
    required this.canSubmitVoice,
  });

  final NormalTopicItem topic;
  final List<String> voices;
  final NormalController controller;
  final bool isEditingVoice;
  final bool isVoiceConfirmed;
  final bool canSubmitVoice;

  String _formatMetoo(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topic.question, style: textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(
              Icons.favorite_rounded,
              size: 15,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${_formatMetoo(topic.metoo)} felt this too',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Divider(color: AppColors.line),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'EXPERT ANSWER · ${topic.expertByline}',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.placeholder,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          topic.expertAnswer,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.warmDark,
            height: 1.9,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Divider(color: AppColors.line),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'OTHERS ARE SAYING',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.placeholder,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(voices.length, (index) {
          final voice = voices[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == voices.length - 1
                  ? AppSpacing.lg
                  : AppSpacing.xl,
            ),
            child: _VoiceQuote(
              text: voice,
              showDivider: index != voices.length - 1,
            ),
          );
        }),
        _TopicNavigation(controller: controller),
        const SizedBox(height: AppSpacing.xl),
        const Divider(color: AppColors.line),
        const SizedBox(height: AppSpacing.lg),
        if (isEditingVoice)
          _VoiceComposer(
            controller: controller,
            canSubmitVoice: canSubmitVoice,
          )
        else if (isVoiceConfirmed)
          _VoiceConfirmation(controller: controller)
        else
          _ActionLinks(controller: controller),
      ],
    );
  }
}

class _VoiceQuote extends StatelessWidget {
  const _VoiceQuote({
    required this.text,
    required this.showDivider,
  });

  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"$text"',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.placeholder,
            fontStyle: FontStyle.italic,
            height: 1.85,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'someone feeling this too',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.line.withOpacity(0.95),
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.line),
        ],
      ],
    );
  }
}

class _TopicNavigation extends StatelessWidget {
  const _TopicNavigation({required this.controller});

  final NormalController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.topics.length;
    final currentIndex = controller.currentCardIndex.value;
    const activeColor = AppColors.primary;
    final inactiveColor = AppColors.line.withOpacity(0.85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            count,
            (index) => Container(
              width: index == currentIndex ? 26 : 10,
              height: 10,
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              decoration: BoxDecoration(
                color: index == currentIndex ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavLink(
              label: 'prev',
              icon: AppIcons.back,
              enabled: controller.hasPreviousTopic,
              alignment: MainAxisAlignment.start,
              onTap: controller.previousTopic,
            ),
            _NavLink(
              label: 'next',
              icon: AppIcons.forward,
              enabled: controller.hasNextTopic,
              alignment: MainAxisAlignment.end,
              onTap: controller.nextTopic,
            ),
          ],
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.alignment,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final MainAxisAlignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.line.withOpacity(0.9);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: alignment,
        children: [
          if (icon == AppIcons.back) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
          ),
          if (icon == AppIcons.forward) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(icon, size: 16, color: color),
          ],
        ],
      ),
    );
  }
}

class _ActionLinks extends StatelessWidget {
  const _ActionLinks({required this.controller});

  final NormalController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionRow(
          label: 'add your voice',
          emphasized: true,
          onTap: controller.addYourVoice,
        ),
        const Divider(color: AppColors.line),
        _ActionRow(
          label: 'ask a different question',
          onTap: controller.askDifferentQuestion,
        ),
      ],
    );
  }
}

class _VoiceConfirmation extends StatelessWidget {
  const _VoiceConfirmation({required this.controller});

  final NormalController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('your voice is in.', style: textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Shared anonymously. Someone will feel less alone because of it.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.placeholder,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        InkWell(
          onTap: controller.dismissVoiceConfirmation,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'back',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                AppIcons.forward,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceComposer extends StatelessWidget {
  const _VoiceComposer({
    required this.controller,
    required this.canSubmitVoice,
  });

  final NormalController controller;
  final bool canSubmitVoice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionColor =
        canSubmitVoice ? AppColors.primary : AppColors.placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR VOICE · ANONYMOUS',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller.voiceInputController,
          onChanged: controller.updateVoiceDraft,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'What has this felt like for you?',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.primary,
            height: 1.8,
          ),
        ),
        const Divider(color: AppColors.line),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: controller.cancelVoiceEntry,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  'cancel',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: canSubmitVoice ? controller.submitVoice : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'share anonymously',
                      style: textTheme.bodyMedium?.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      AppIcons.forward,
                      size: 16,
                      color: actionColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = emphasized ? AppColors.primary : AppColors.placeholder;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ),
            Icon(AppIcons.forward, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
