import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class MinimalAudioBar extends StatelessWidget {
  const MinimalAudioBar({
    super.key,
    required this.primaryLabel,
    this.secondaryLabel,
    this.inverse = false,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final foreground = inverse ? AppColors.white : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: foreground.withOpacity(0.18), height: 1),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _CircleAction(icon: Icons.replay_10_rounded, color: foreground),
            const SizedBox(width: AppSpacing.md),
            _CircleAction(
              icon: Icons.play_arrow_rounded,
              color: foreground,
              filled: true,
              inverse: inverse,
            ),
            const SizedBox(width: AppSpacing.md),
            _CircleAction(icon: Icons.forward_10_rounded, color: foreground),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  primaryLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: foreground,
                      ),
                ),
                if (secondaryLabel != null)
                  Text(
                    secondaryLabel!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: foreground.withOpacity(0.7),
                        ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    this.filled = false,
    this.inverse = false,
  });

  final IconData icon;
  final Color color;
  final bool filled;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final fill =
        inverse ? AppColors.white.withOpacity(0.14) : AppColors.surface;

    return Container(
      width: filled ? 48 : 42,
      height: filled ? 48 : 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? fill : Colors.transparent,
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Icon(icon, color: color),
    );
  }
}
