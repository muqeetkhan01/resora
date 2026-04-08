import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';

class ResoraLoadingOverlay extends StatefulWidget {
  const ResoraLoadingOverlay({super.key});

  @override
  State<ResoraLoadingOverlay> createState() => _ResoraLoadingOverlayState();
}

class _ResoraLoadingOverlayState extends State<ResoraLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.canvas.withOpacity(0.94),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_controller.value);
            final accentWidth = 48.0 + (t * 28.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.985 + (t * 0.03),
                  child: Opacity(
                    opacity: 0.72 + (t * 0.28),
                    child: Text(
                      'resora',
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.6 + (t * 1.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    width: accentWidth,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
