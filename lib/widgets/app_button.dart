import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final foreground = switch (style) {
      AppButtonStyle.primary => Colors.white,
      AppButtonStyle.secondary => AppColors.ink,
      AppButtonStyle.ghost => AppColors.ink,
    };

    final background = switch (style) {
      AppButtonStyle.primary => AppColors.ink,
      AppButtonStyle.secondary => Colors.white.withOpacity(0.8),
      AppButtonStyle.ghost => Colors.transparent,
    };

    final border = switch (style) {
      AppButtonStyle.primary => Colors.transparent,
      AppButtonStyle.secondary => AppColors.line,
      AppButtonStyle.ghost => Colors.transparent,
    };

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: border),
        boxShadow: style == AppButtonStyle.primary
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: expanded ? button : IntrinsicWidth(child: button),
    );
  }
}
