import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_icons.dart';
import '../core/constants/app_spacing.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.backgroundColor = AppColors.canvas,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: safeArea ? SafeArea(child: child) : child,
        ),
      ),
    );

    final body = Stack(
      children: [
        Container(
          color: backgroundColor,
        ),
        content,
      ],
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: body,
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
            color: AppColors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: AppColors.line.withOpacity(0.9)),
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
        Icon(
          AppIcons.brand,
          size: size * 0.48,
          color: AppColors.primary,
        ),
        if (showWordmark) ...[
          const SizedBox(height: AppSpacing.md),
          Text('resora', style: textTheme.displayLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'for real life moments',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
