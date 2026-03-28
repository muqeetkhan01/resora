import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class PremiumLockOverlay extends StatelessWidget {
  const PremiumLockOverlay({
    super.key,
    required this.show,
    this.compact = false,
  });

  final bool show;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      top: compact ? 10 : AppSpacing.md,
      right: compact ? 10 : AppSpacing.md,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: compact ? 11 : 14,
              color: AppColors.ink,
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              compact ? 'Pro' : 'Premium',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 10 : 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
