import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/controllers/app_session_controller.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_close_button.dart';
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
      onPopInvokedWithResult: (didPop, _) {
        controller.dismissKeyboard();
        if (!didPop && showRitualExit) {
          _openRitualExit(routeArgs.ritualFeature!);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: controller.dismissKeyboard,
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ChatContent(
                rootTab: rootTab,
                onBack: showRitualExit
                    ? () => _openRitualExit(routeArgs.ritualFeature!)
                    : () {
                        controller.dismissKeyboard();
                        Get.back();
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRitualExit(String feature) {
    controller.dismissKeyboard();
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
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChatHeader(
          rootTab: rootTab,
          onBack: onBack,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Obx(() {
            final showDailyLimit = controller.isDailyLimitReached.value &&
                !controller.hasPremiumAccess;
            final showWatermark = controller.messages.isEmpty &&
                !controller.isTyping.value &&
                !showDailyLimit;
            final totalCount = controller.messages.length +
                (controller.isTyping.value ? 1 : 0) +
                (showDailyLimit ? 1 : 0);

            if (showWatermark) {
              return _EmptyStatePrompt(
                line: controller.sessionLine,
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                top: AppSpacing.xs,
                bottom: keyboardVisible ? AppSpacing.lg : AppSpacing.md,
              ),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                if (index >= controller.messages.length) {
                  final typingIndex = controller.messages.length;
                  if (controller.isTyping.value && index == typingIndex) {
                    return const _TypingBubble();
                  }
                  return _DailyLimitCard(
                    onExplorePremium: controller.openMembership,
                  );
                }

                return _MessageBubble(message: controller.messages[index]);
              },
            );
          }),
        ),
        // Obx(() {
        //   final showQuickStart =
        //       controller.messages.isEmpty && !controller.isTyping.value;
        //   if (!showQuickStart) {
        //     return const SizedBox.shrink();
        //   }
        //   return const _QuickStartActionsRow();
        // }),
        SizedBox(height: keyboardVisible ? AppSpacing.sm : AppSpacing.lg),
        const _ChatInputBar(),
        SizedBox(height: keyboardVisible ? AppSpacing.xs : AppSpacing.sm),
        const _GlobalChatDisclaimer(),
        if (rootTab) ...[
          SizedBox(height: keyboardVisible ? AppSpacing.xs : AppSpacing.sm),
          // const Divider(height: 1, color: AppColors.line),
        ],
        SizedBox(height: keyboardVisible ? AppSpacing.sm : AppSpacing.lg),
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
    if (rootTab) {
      return const SizedBox(height: AppSpacing.lg);
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppCloseButton(onPressed: onBack),
      ),
    );
  }
}

class _EmptyStatePrompt extends StatelessWidget {
  const _EmptyStatePrompt({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Align(
        alignment: const Alignment(-1, 0.3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resora',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.5),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              line,
              style: textTheme.displayLarge?.copyWith(
                fontSize: 48,
                height: 1.1,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
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
                child: TextField(
                  controller: controller.inputController,
                  focusNode: controller.inputFocusNode,
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
                  onTapOutside: (_) => controller.dismissKeyboard(),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
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
                    color:
                        canSend ? AppColors.terracotta : AppColors.placeholder,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            color: AppColors.primary.withValues(alpha: 0.15),
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

class _DailyLimitCard extends StatelessWidget {
  const _DailyLimitCard({required this.onExplorePremium});

  final VoidCallback onExplorePremium;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.terracotta.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.terracotta.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You’ve reached today’s free chat limit. Upgrade to Premium to keep talking with Resora today.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.warmDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onExplorePremium,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'CONTINUE WITH PREMIUM',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
                letterSpacing: 1.3,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.terracotta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobalChatDisclaimer extends StatelessWidget {
  const _GlobalChatDisclaimer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      'Resora provides general support and reflection tools. It is not therapy, medical care, legal advice, emergency support, or crisis care. If you may hurt yourself or someone else, or someone is in immediate danger, contact emergency services or a crisis line now.',
      style: textTheme.bodySmall?.copyWith(
        color: AppColors.placeholder,
        height: 1.35,
      ),
    );
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
            ? 'You'
            : Get.find<AppSessionController>().displayName;
    final speaker = isUser ? currentUserName : 'Resora';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
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
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.terracotta.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 6),
                      bottomRight: Radius.circular(isUser ? 6 : 16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.terracotta.withValues(alpha: 0.25)
                          : AppColors.line,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                      height: 1.68,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  'Resora',
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
