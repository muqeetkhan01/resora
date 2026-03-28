import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.gradient,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? (gradient == null ? AppColors.card : null),
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.line),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 28,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
