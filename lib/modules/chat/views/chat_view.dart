import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/controllers/app_session_controller.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../../ritual_wrap/models/ritual_wrap_args.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key, this.rootTab = false});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    final routeArgs = _ChatRouteArgs.from(Get.arguments);
    final showRitualExit =
        !rootTab && routeArgs.ritualFeature == RitualWrapFeature.talk;

    return PopScope(
      canPop: !showRitualExit,
      onPopInvoked: (didPop) {
        if (!didPop && showRitualExit) {
          _openRitualExit(routeArgs.ritualFeature!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ChatContent(
              rootTab: rootTab,
              onBack: showRitualExit
                  ? () => _openRitualExit(routeArgs.ritualFeature!)
                  : () => Get.back(),
            ),
          ),
        ),
      ),
    );
  }

  void _openRitualExit(String feature) {
    Get.offNamed(
      AppRoutes.ritualWrap,
      arguments: RitualWrapArgs.exit(feature: feature).toMap(),
    );
  }
}

class _ChatContent extends GetView<ChatController> {
  const _ChatContent({
    required this.rootTab,
    required this.onBack,
  });

  final bool rootTab;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChatHeader(
          rootTab: rootTab,
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Obx(() {
            final showWatermark =
                controller.messages.isEmpty && !controller.isTyping.value;
            final totalCount = controller.messages.length +
                (controller.isTyping.value ? 1 : 0);

            if (showWatermark) {
              return _TalkEmptyStateWithPrompt(
                line: controller.sessionLine,
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                if (index >= controller.messages.length) {
                  return const _TypingBubble();
                }

                return _MessageBubble(message: controller.messages[index]);
              },
            );
          }),
        ),
        Obx(() {
          final showQuickStart =
              controller.messages.isEmpty && !controller.isTyping.value;
          if (!showQuickStart) {
            return const SizedBox.shrink();
          }
          return const _QuickStartActionsRow();
        }),
        const SizedBox(height: AppSpacing.sm),
        const _ChatInputBar(),
        if (rootTab) ...[
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.line),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.rootTab,
    required this.onBack,
  });

  final bool rootTab;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!rootTab)
            IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                size: 15,
                color: AppColors.terracotta,
              ),
            ),
          if (!rootTab) const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'resora',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.terracotta,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  chatController.sessionLine.toLowerCase(),
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                    height: 1.02,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TalkEmptyStateWithPrompt extends StatelessWidget {
  const _TalkEmptyStateWithPrompt({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _TalkEmptyState(),
        _ChatPromptState(line: line),
      ],
    );
  }
}

class _ChatRouteArgs {
  const _ChatRouteArgs({
    this.ritualFeature,
  });

  final String? ritualFeature;

  factory _ChatRouteArgs.from(dynamic value) {
    if (value is Map) {
      return _ChatRouteArgs(
        ritualFeature: value['ritualFeature'] as String?,
      );
    }

    return const _ChatRouteArgs();
  }
}

class _TalkEmptyState extends StatelessWidget {
  const _TalkEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'R',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 160,
              height: 1,
              color: AppColors.primary.withOpacity(0.045),
              letterSpacing: -4,
            ),
      ),
    );
  }
}

class _ChatPromptState extends StatelessWidget {
  const _ChatPromptState({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'resora',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.terracotta,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              line,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 40,
                    height: 1.15,
                    fontStyle: FontStyle.normal,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 28,
              height: 0.8,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStartActionsRow extends GetView<ChatController> {
  const _QuickStartActionsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary.withOpacity(0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: ChatController.quickStartActions.map((label) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: OutlinedButton(
                onPressed: () => controller.sendMessage(label),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary.withOpacity(0.16)),
                  foregroundColor: AppColors.placeholder,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.placeholder,
                        letterSpacing: 0.15,
                        fontStyle: FontStyle.normal,
                      ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _ChatInputBar extends GetView<ChatController> {
  const _ChatInputBar();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final canSend = controller.canSend;
      final showWarning = controller.shouldShowCharacterWarning;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.72)),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: TextField(
                    controller: controller.inputController,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: ChatController.maxCharacters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        ChatController.maxCharacters,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      ),
                    ],
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    cursorColor: AppColors.primary,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.normal,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      counterText: '',
                      hintText: 'Share what\'s happening...',
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: AppColors.placeholder,
                        fontStyle: FontStyle.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: canSend ? controller.sendMessage : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.sm,
                  ),
                  child: Icon(
                    AppIcons.forward,
                    size: 16,
                    color: canSend
                        ? AppColors.terracotta
                        : AppColors.terracotta.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
          if (showWarning)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Take your time — no need to fit everything into one message. Send what you have and keep going.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.placeholder,
                  height: 1.4,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUser = message.isUser;
    final currentUserName =
        Get.find<AppSessionController>().displayName == 'there'
            ? 'you'
            : Get.find<AppSessionController>().displayName;
    final speaker = isUser ? currentUserName : 'resora';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const _MessageAvatar(isUser: false),
            const SizedBox(width: AppSpacing.xs),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    speaker,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.placeholder,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    message.text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: isUser ? AppColors.white : AppColors.text,
                      height: 1.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.xs),
            const _MessageAvatar(isUser: true),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MessageAvatar(isUser: false),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  'resora',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholder,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(),
                    SizedBox(width: 5),
                    _Dot(),
                    SizedBox(width: 5),
                    _Dot(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  const _MessageAvatar({required this.isUser});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.line),
      ),
      child: Center(
        child: isUser
            ? const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.primary,
              )
            : Text(
                'R',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                      height: 1,
                    ),
              ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
