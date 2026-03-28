import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class PremiumLockOverlay extends StatelessWidget {
  const PremiumLockOverlay({super.key, required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Premium',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
