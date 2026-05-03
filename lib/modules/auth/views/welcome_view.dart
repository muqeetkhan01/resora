import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../widgets/app_background.dart';
import '../controllers/auth_entry_controller.dart';
import '../widgets/resora_loading_overlay.dart';

class WelcomeView extends GetView<AuthEntryController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Obx(
        () => Stack(
          children: [
            IgnorePointer(
              ignoring: controller.isSubmitting.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xxl,
                  bottom: AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 86),
                    Text(
                      'resora',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 78,
                        letterSpacing: 0.22,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 52,
                      height: 1,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Life gets better when you do.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'ENTER',
                      style: textTheme.labelMedium?.copyWith(
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _AuthOptionTile(
                            icon: Icons.apple,
                            label: controller.activeProvider.value == 'apple'
                                ? 'Connecting...'
                                : 'Continue with Apple',
                            onTap: controller.isSubmitting.value
                                ? null
                                : controller.continueWithApple,
                          ),
                          _AuthOptionTile(
                            leadingText: 'G',
                            label: controller.activeProvider.value == 'google'
                                ? 'Connecting...'
                                : 'Continue with Google',
                            onTap: controller.isSubmitting.value
                                ? null
                                : controller.continueWithGoogle,
                          ),
                          _AuthOptionTile(
                            leadingText: '→',
                            label: 'Continue with email',
                            onTap: controller.isSubmitting.value
                                ? null
                                : controller.continueWithEmail,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'By continuing, you agree to our Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.74),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.signIn,
                      child: Text(
                        'Already have an account? sign in',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.78),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !controller.isSubmitting.value,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: controller.isSubmitting.value ? 1 : 0,
                  child: const ResoraLoadingOverlay(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthOptionTile extends StatelessWidget {
  const _AuthOptionTile({
    required this.label,
    required this.onTap,
    this.icon,
    this.leadingText,
    this.isLast = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? leadingText;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lineColor = Theme.of(context).colorScheme.primary.withOpacity(0.16);

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : lineColor,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: icon != null
                  ? Icon(
                      icon,
                      size: 21,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.66),
                    )
                  : Text(
                      leadingText ?? '',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 27,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.66),
                        height: 1,
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  letterSpacing: 0.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
