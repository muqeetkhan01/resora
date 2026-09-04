import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_entry_controller.dart';
import '../widgets/resora_loading_overlay.dart';

class WelcomeView extends GetView<AuthEntryController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final showAppleSignIn = GetPlatform.isIOS || GetPlatform.isMacOS;

    return Scaffold(
      body: Obx(
        () => Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.authWelcomeBg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.44),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.06),
                    Colors.black.withOpacity(0.30),
                    Colors.black.withOpacity(0.78),
                    Colors.black.withOpacity(0.92),
                  ],
                  stops: const [0, 0.17, 0.42, 0.64, 0.82, 1],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.48),
                      Colors.black.withOpacity(0.88),
                    ],
                    stops: const [0, 0.38, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: IgnorePointer(
                ignoring: controller.isSubmitting.value,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 48, 26, 34),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resora',
                        style: GoogleFonts.jost(
                          color: Colors.white.withOpacity(0.94),
                          fontSize: 21,
                          fontWeight: FontWeight.w200,
                          height: 1,
                          letterSpacing: 2.9,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (showAppleSignIn) ...[
                            Expanded(
                              child: _AuthImageButton(
                                icon: Icons.apple,
                                label:
                                    controller.activeProvider.value == 'apple'
                                        ? 'Connecting...'
                                        : 'Continue with Apple',
                                onTap: controller.isSubmitting.value
                                    ? null
                                    : controller.continueWithApple,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: _AuthImageButton(
                              google: true,
                              label: controller.activeProvider.value == 'google'
                                  ? 'Connecting...'
                                  : 'Continue with Google',
                              onTap: controller.isSubmitting.value
                                  ? null
                                  : controller.continueWithGoogle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.continueWithEmail,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Continue with email',
                            style: GoogleFonts.jost(
                              color: Colors.white.withOpacity(0.86),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white.withOpacity(0.86),
                              decorationThickness: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: TextButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.signIn,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.82),
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        Colors.white.withOpacity(0.82),
                                    decorationThickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jost(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _LegalLinks(),
                    ],
                  ),
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

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.jost(
      color: Colors.white.withValues(alpha: 0.52),
      fontSize: 10,
      fontWeight: FontWeight.w400,
      height: 1.35,
    );
    final linkStyle = baseStyle.copyWith(
      color: Colors.white.withValues(alpha: 0.74),
      decoration: TextDecoration.underline,
      decorationColor: Colors.white.withValues(alpha: 0.74),
      decorationThickness: 1,
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('By continuing, you agree to our ', style: baseStyle),
          _InlineLegalButton(
            label: 'Terms',
            style: linkStyle,
            onTap: () => Get.toNamed(AppRoutes.termsOfUse),
          ),
          Text(' and ', style: baseStyle),
          _InlineLegalButton(
            label: 'Privacy Policy',
            style: linkStyle,
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          Text('.', style: baseStyle),
        ],
      ),
    );
  }
}

class _InlineLegalButton extends StatelessWidget {
  const _InlineLegalButton({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
        child: Text(label, style: style),
      ),
    );
  }
}

class _AuthImageButton extends StatelessWidget {
  const _AuthImageButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.google = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool google;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF4EF).withOpacity(0.96),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 50,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (google)
                  Text(
                    'G',
                    style: GoogleFonts.jost(
                      color: const Color(0xFF4285F4),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  )
                else
                  Icon(
                    icon,
                    size: 21,
                    color: const Color(0xFF151515),
                  ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.jost(
                    color: const Color(0xFF151515),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: -0.1,
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
