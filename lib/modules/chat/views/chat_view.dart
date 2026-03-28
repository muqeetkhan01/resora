import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(AppIcons.back),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Calm AI Guide', style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text('Private reflection companion',
                          style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.cardStrong,
                  child: Icon(AppIcons.aiGuidance, color: AppColors.ink),
                ),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Try a prompt', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: controller.suggestions
                      .map(
                        (prompt) => AppTagChip(
                          label: prompt,
                          onTap: () => controller.sendMessage(prompt),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                itemCount: controller.messages.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? AppColors.ink
                              : Colors.white.withOpacity(0.82),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Column(
                          crossAxisAlignment: message.isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: textTheme.bodyLarge?.copyWith(
                                color: message.isUser
                                    ? Colors.white
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              message.time,
                              style: textTheme.bodySmall?.copyWith(
                                color: message.isUser
                                    ? Colors.white.withOpacity(0.7)
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
                bottom: AppSpacing.lg, top: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.inputController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share what feels heavy or tender today...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.82),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: controller.sendMessage,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(AppIcons.send, color: Colors.white),
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
