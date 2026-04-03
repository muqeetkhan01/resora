import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/minimal_audio_bar.dart';

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

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.back, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(track.title, style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                track.description,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE9ECE7), Color(0xFFDDE4DF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      AppIcons.noise,
                      color: AppColors.primary.withOpacity(0.6),
                      size: 54,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              MinimalAudioBar(
                primaryLabel: track.duration,
                secondaryLabel: track.category,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
