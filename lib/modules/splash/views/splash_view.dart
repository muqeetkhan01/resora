import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../controllers/splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      safeArea: false,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 900),
          opacity: _visible ? 1 : 0,
          curve: Curves.easeOut,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: _visible ? 1 : 0.92),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ResoraLogo(size: 104, showWordmark: false),
                const SizedBox(height: AppSpacing.xl),
                Text('Resora', style: textTheme.displayLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A premium space for calm parenting and emotional wellness',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
