import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_snackbar.dart';

class ThatMatteredView extends StatelessWidget {
  const ThatMatteredView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0E2A27),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _MoodyTextureBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Text(
                    'that mattered',
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.88),
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'you gave yourself a moment',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withOpacity(0.46),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 6),
                  SizedBox(
                    width: 320,
                    child: _GlassOutlineButton(
                      label: 'save this moment',
                      onTap: () => showAppSnackbar(
                        'Saved',
                        'This moment is saved locally in the prototype.',
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: AppColors.white,
                        backgroundColor: const Color(0xFF173C38),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                      width: 320,
                      child: _GlassOutlineButton(
                        label: 'continue',
                        emphasize: true,
                        onTap: () => Get.offAllNamed(AppRoutes.dashboard),
                      )),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodyTextureBackground extends StatelessWidget {
  const _MoodyTextureBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 1.1,
              colors: [
                Color(0xFF274C47),
                Color(0xFF153632),
                Color(0xFF0D2421),
              ],
            ),
          ),
        ),
        ...List.generate(16, (index) {
          final top = (index * 53.0) % 760;
          final left = (index * 41.0) % 360;
          final size = 120.0 + (index % 4) * 34.0;

          return Positioned(
            top: top,
            left: left - 60,
            child: IgnorePointer(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.white.withOpacity(index.isEven ? 0.035 : 0.018),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _GlassOutlineButton extends StatelessWidget {
  const _GlassOutlineButton({
    required this.label,
    required this.onTap,
    this.emphasize = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: emphasize
              ? AppColors.white.withOpacity(0.02)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColors.white.withOpacity(0.14),
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.76),
              ),
        ),
      ),
    );
  }
}
