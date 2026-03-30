import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/resets_controller.dart';

class ResetsView extends GetView<ResetsController> {
  const ResetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.close, color: AppColors.primary),
              ),
              Text('gentle resets', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Regulation before reflection.', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    const _BreathingCircle(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Breathe in. Hold. Breathe out.',
                      style: textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Start here when the moment is moving faster than you are.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        _DurationPill(label: '2 min', selected: true),
                        _DurationPill(label: '5 min'),
                        _DurationPill(label: 'custom'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const AppButton(
                      label: 'Start breath reset',
                      icon: AppIcons.play,
                      onPressed: null,
                      expanded: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...controller.options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(option.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.title, style: textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(option.subtitle, style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Text(option.duration, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'After any reset, the next step can be journal, home, or one more round.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingCircle extends StatelessWidget {
  const _BreathingCircle();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.84, end: 1),
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 154,
        height: 154,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.06),
          border: Border.all(color: AppColors.primary.withOpacity(0.16), width: 1.6),
        ),
        child: Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.22)),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppColors.primary : AppColors.line),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? AppColors.white : AppColors.primary,
            ),
      ),
    );
  }
}
