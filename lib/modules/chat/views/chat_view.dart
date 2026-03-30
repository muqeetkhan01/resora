import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key, this.rootTab = false});

  final bool rootTab;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: Row(
            children: [
              if (!rootTab)
                GestureDetector(
                  onTap: Get.back,
                  child: const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.md),
                    child: Icon(AppIcons.back, color: AppColors.primary),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      rootTab ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Text(
                      'talk to resora',
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'a calm place for in the moment support',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  AppIcons.brand,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('start here', style: textTheme.labelLarge),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.suggestions
                .map(
                  (prompt) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: AppTagChip(
                      label: prompt,
                      onTap: () => controller.sendMessage(prompt),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];

                return _MessageBubble(message: message);
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.lg),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.inputController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your thoughts...',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.send,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isUser ? 'You' : 'Resora',
            style: textTheme.bodySmall?.copyWith(
              color: isUser ? AppColors.muted : AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUser ? AppColors.primary : AppColors.line,
                ),
              ),
              child: Text(
                message.text,
                style: textTheme.bodyLarge?.copyWith(
                  color: isUser ? AppColors.white : AppColors.warmDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
