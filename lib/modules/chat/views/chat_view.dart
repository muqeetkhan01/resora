import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key, this.rootTab = false});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    final content = _ChatContent(rootTab: rootTab);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: content,
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final showIntroHeader = rootTab &&
              controller.messages.isEmpty &&
              !controller.isTyping.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: showIntroHeader
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'talk to resora',
                                  style: textTheme.displayLarge,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'support for the moment you are in.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.placeholder,
                                  ),
                                ),
                              ],
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
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!rootTab) ...[
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
                          ],
                          Expanded(
                            child: Text(
                              'what\'s on your mind?',
                              style: textTheme.displayMedium,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
            ],
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Obx(() {
            final showEmpty =
                controller.messages.isEmpty && !controller.isTyping.value;

            if (showEmpty) {
              return _EmptyState(rootTab: rootTab);
            }

            final totalCount = controller.messages.length +
                (controller.isTyping.value ? 1 : 0);

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'what\'s on your mind?',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 14,
                  ),
                  filled: false,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton(
              onPressed: controller.sendMessage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                AppIcons.send,
                color: AppColors.terracotta,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.rootTab});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (rootTab) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Text(
          'Start with one clear sentence.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.placeholder,
          ),
        ),
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
            ? 'user'
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
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.chatOutline,
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
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
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isUser ? 14 : 3),
                      bottomRight: Radius.circular(isUser ? 3 : 14),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: isUser ? AppColors.white : AppColors.text,
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
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(AppIcons.chatOutline,
                size: 16, color: AppColors.primary),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
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
