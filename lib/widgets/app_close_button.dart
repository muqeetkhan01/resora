import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Close',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.terracotta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: const SizedBox.square(
            dimension: 32,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ),
    );
  }
}
