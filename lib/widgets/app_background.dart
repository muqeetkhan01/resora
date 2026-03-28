import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        Container(
            decoration: const BoxDecoration(gradient: AppColors.dawnGradient)),
        const _GlowOrb(top: -30, left: -20, color: AppColors.peach, size: 200),
        const _GlowOrb(top: 170, right: -50, color: AppColors.sage, size: 170),
        const _GlowOrb(
            bottom: -60, left: 40, color: AppColors.blush, size: 220),
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: safeArea ? SafeArea(child: body) : body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class FrostedPill extends StatelessWidget {
  const FrostedPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: Colors.white.withOpacity(0.65)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResoraLogo extends StatelessWidget {
  const ResoraLogo({super.key, this.size = 84, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF6DEC9), Color(0xFFEBC0BA), Color(0xFFE9D8BE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size / 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 40,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.62,
                height: size * 0.62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(size / 4),
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                size: size * 0.34,
                color: AppColors.ink,
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Resora', style: textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Calm living for tender seasons',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.color,
    required this.size,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.16),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
