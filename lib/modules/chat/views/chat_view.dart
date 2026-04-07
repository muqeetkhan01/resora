import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/controllers/app_session_controller.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key, this.rootTab = false});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ChatContent(rootTab: rootTab),
          ),
        ),
      ),
    );
  }
}

class _ChatContent extends GetView<ChatController> {
  const _ChatContent({required this.rootTab});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _ChatHeader(
            rootTab: rootTab,
            showConversationHeader: controller.messages.isNotEmpty,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: Obx(() {
            final showWatermark = rootTab &&
                controller.messages.isEmpty &&
                !controller.isTyping.value;
            final totalCount = controller.messages.length +
                (controller.isTyping.value ? 1 : 0);

            if (showWatermark) {
              return const _TalkEmptyState();
            }

            if (totalCount == 0) {
              return const _ChatPromptState();
            }

            return ListView.builder(
              controller: controller.scrollController,
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
        const SizedBox(height: AppSpacing.sm),
        _ChatInputBar(rootTab: rootTab),
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
    required this.showConversationHeader,
  });

  final bool rootTab;
  final bool showConversationHeader;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (rootTab) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
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
              'what\'s on your\nmind?',
              style: textTheme.displayLarge?.copyWith(
                fontSize: 34,
                height: 1.08,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '3 free messages left today',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.placeholder,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: Get.back,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              AppIcons.back,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              showConversationHeader
                  ? 'what\'s on your mind?'
                  : 'talk to resora',
              style: textTheme.displayMedium,
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
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
  const _ChatPromptState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Text(
          'Start with one clear sentence.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.placeholder,
              ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends GetView<ChatController> {
  const _ChatInputBar({required this.rootTab});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final canSend = controller.canSend;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.primary.withOpacity(0.72)),
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
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(),
                cursorColor: AppColors.primary,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  hintText: rootTab
                      ? 'share what is happening...'
                      : 'share what is happening...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: AppColors.placeholder,
                    fontStyle: FontStyle.italic,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          !canSend ? const SizedBox() : const SizedBox(width: AppSpacing.sm),
          !canSend
              ? const SizedBox()
              : InkWell(
                  onTap: canSend ? controller.sendMessage : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.sm,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: canSend
                          ? AppColors.terracotta
                          : AppColors.placeholder,
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
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: const Center(
                child: Text(
                  'R',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 18,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
              ),
            ),
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
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Center(
              child: Text(
                'R',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 18,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
            ),
          ),
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
