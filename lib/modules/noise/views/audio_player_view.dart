import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';

class AudioPlayerView extends StatelessWidget {
  const AudioPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final track = Get.arguments as AudioTrack? ??
        const AudioTrack(
          title: 'Soft rain on leaves',
          category: 'Nature',
          description: 'Steady sound for nervous-system downshift',
          duration: '18 min',
        );
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(AppIcons.close, color: AppColors.primary),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, style: textTheme.displayMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${track.category} • ${track.duration}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.canvas,
                    AppColors.sage.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.14)),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.86),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.pause_rounded, color: AppColors.primary, size: 38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(track.description, style: textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: const LinearProgressIndicator(
                value: 0.33,
                minHeight: 4,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text('03:18', style: textTheme.bodySmall),
                const Spacer(),
                Text('18:00', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundAction(icon: Icons.replay_10_rounded),
                _RoundAction(icon: Icons.play_arrow_rounded, filled: true),
                _RoundAction(icon: Icons.forward_10_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _MetaPill(label: 'Sleep timer'),
                _MetaPill(label: 'Transcript'),
                _MetaPill(label: 'Save offline'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Keep playing in background',
              style: AppButtonStyle.secondary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    this.filled = false,
  });

  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: filled ? 72 : 58,
      height: filled ? 72 : 58,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: filled ? AppColors.primary : AppColors.line),
      ),
      child: Icon(
        icon,
        color: filled ? AppColors.white : AppColors.primary,
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
      ),
    );
  }
}
