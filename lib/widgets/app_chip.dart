import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppTagChip extends StatelessWidget {
  const AppTagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.success : AppColors.shell.withOpacity(0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.success : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.ink,
              ),
        ),
      ),
    );
  }
}
