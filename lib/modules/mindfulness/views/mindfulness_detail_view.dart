import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../controllers/mindfulness_controller.dart';

class MindfulnessDetailView extends GetView<MindfulnessController> {
  const MindfulnessDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.arguments as MindfulnessSession;
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
              ),
            ),
            AppCard(
              gradient: LinearGradient(
                colors: [
                  session.color.withOpacity(0.42),
                  Colors.white.withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.type, style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(session.title, style: textTheme.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(session.subtitle, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Length: ${session.length}',
                      style: textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What to expect', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'This detail screen is ready for future audio playback, transcripts, session progress, and premium access logic.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Play session',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => controller.playSession(session),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
