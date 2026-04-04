import 'package:flutter/material.dart';

import '../core/constants/app_icons.dart';
import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class LinkActionRow extends StatelessWidget {
  const LinkActionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.alignStart = true,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: alignStart ? Alignment.centerLeft : Alignment.center,
        foregroundColor: color,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(AppIcons.forward, size: 16, color: color),
        ],
      ),
    );
  }
}
