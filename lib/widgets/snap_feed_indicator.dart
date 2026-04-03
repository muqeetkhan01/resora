import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class SnapFeedIndicator extends StatelessWidget {
  const SnapFeedIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.color = AppColors.primary,
  });

  final int count;
  final int currentIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => Container(
          width: 4,
          height: index == currentIndex ? 18 : 8,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
          decoration: BoxDecoration(
            color: index == currentIndex ? color : color.withOpacity(0.22),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
