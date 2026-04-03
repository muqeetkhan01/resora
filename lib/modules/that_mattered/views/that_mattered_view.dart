import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';

class ThatMatteredView extends StatelessWidget {
  const ThatMatteredView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      backgroundColor: AppColors.forest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            'that mattered',
            style: textTheme.displayMedium?.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'you gave yourself a moment',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withOpacity(0.72),
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _ThatMatteredButton(
            label: 'save this moment',
            onTap: () => Get.snackbar(
              'Saved',
              'This moment is saved locally in the prototype.',
              snackPosition: SnackPosition.BOTTOM,
              colorText: AppColors.white,
              backgroundColor: AppColors.primary.withOpacity(0.94),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ThatMatteredButton(
            label: 'continue',
            filled: true,
            onTap: () => Get.offAllNamed(AppRoutes.dashboard),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ThatMatteredButton extends StatelessWidget {
  const _ThatMatteredButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: filled ? AppColors.terracotta : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: filled
                  ? AppColors.terracotta
                  : AppColors.white.withOpacity(0.18),
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
              ),
        ),
      ),
    );
  }
}
