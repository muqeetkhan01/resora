import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resora/theme/app_colors.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_spacing.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final currentStep = controller.clampedStep;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<int>(currentStep),
            child: _buildStep(context, currentStep),
          ),
        );
      }),
    );
  }

  Widget _buildStep(BuildContext context, int step) {
    return switch (step) {
      0 => _CoverScreen(
          onNext: controller.next,
          onSignIn: controller.enterApp,
        ),
      1 => _NameScreen(controller: controller),
      2 => _ReasonsScreen(controller: controller),
      3 => _StateScreen(controller: controller),
      4 => _IntentionScreen(controller: controller),
      5 => _GlimpseScreen(controller: controller),
      _ => _PaywallScreen(controller: controller),
    };
  }
}

class _OnboardingTokens {
  static const Color green = Color(0xFF145C4F);
  static const Color off = Color(0xFFFAFBF9);
  static const Color dark = Color(0xFF151515);
  static const Color stone = Color(0xFFE3DED5);
  static const Color linen = Color(0xFFD7CFC2);
  static const Color taupe = Color(0xFF151515);
  static const Color cream = Color(0xFFF5F2EC);
}

class _FlowScreen extends StatelessWidget {
  const _FlowScreen({
    required this.child,
    this.step,
    this.total,
    this.onBack,
    this.scrollable = false,
  });

  final Widget child;
  final int? step;
  final int? total;
  final VoidCallback? onBack;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    const muted = _OnboardingTokens.taupe;
    const track = _OnboardingTokens.stone;
    const progressColor = _OnboardingTokens.green;

    return DecoratedBox(
      decoration: const BoxDecoration(color: _OnboardingTokens.off),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _WatercolorBackdrop(
            accent: _OnboardingTokens.dark,
            opacity: 0.08,
          ),
          SafeArea(
            child: Column(
              children: [
                if (step != null && total != null)
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(height: 1, color: track),
                        FractionallySizedBox(
                          widthFactor: (step! / total!).clamp(0.0, 1.0),
                          child: Container(
                            height: 1,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Row(
                    children: [
                      if (onBack != null)
                        TextButton(
                          onPressed: onBack,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: muted,
                          ),
                          child: Text(
                            'Back',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: muted,
                                  letterSpacing: 2.6,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: scrollable
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: child,
                          )
                        : child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverScreen extends StatelessWidget {
  const _CoverScreen({
    required this.onNext,
    required this.onSignIn,
  });

  final VoidCallback onNext;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.onboardingOpenBg),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        color: Color(0xFF09110E),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.06),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0, 0.4, 0.62, 0.94, 1],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF020807).withValues(alpha: 0.32),
                    const Color(0xFF020807).withValues(alpha: 0.68),
                  ],
                  stops: const [0, 0.68, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 44, 28, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resora',
                    style: GoogleFonts.cormorantGaramond(
                      color: AppColors.primary,
                      fontSize: 54,
                      fontWeight: FontWeight.w400,
                      height: 0.92,
                      letterSpacing: 0.01,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                  Text(
                    'Life gets better when you do.',
                    style: GoogleFonts.cormorantGaramond(
                      color: _OnboardingTokens.off,
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      height: 0.9,
                      letterSpacing: -0.015,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 144,
                          height: 50,
                          child: FilledButton(
                            onPressed: onNext,
                            style: FilledButton.styleFrom(
                              backgroundColor: _OnboardingTokens.cream,
                              foregroundColor: const Color(0xFF2C4138),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.jost(
                                color: const Color(0xFF151515),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Center(
                          child: TextButton(
                            onPressed: onSignIn,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateScreen extends StatelessWidget {
  const _StateScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FlowScreen(
      step: 3,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Obx(() {
        final selectedStates = controller.selectedStates.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'How are\nyou feeling?',
              style: textTheme.displayLarge?.copyWith(
                color: _OnboardingTokens.dark,
                fontSize: 50,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'No right or wrong answers here. Pick as many as you need.',
                style: textTheme.bodySmall?.copyWith(
                  color: _OnboardingTokens.dark.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ...OnboardingController.states.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = selectedStates.contains(item.key);
              return InkWell(
                onTap: () => controller.toggleStateValue(item.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: entry.key == 0
                            ? _OnboardingTokens.linen
                            : Colors.transparent,
                        width: 0.5,
                      ),
                      bottom: const BorderSide(
                        color: _OnboardingTokens.linen,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? _OnboardingTokens.green
                                : _OnboardingTokens.dark,
                            fontSize: 13,
                            letterSpacing: 0.05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: isSelected
                                ? _OnboardingTokens.green
                                : _OnboardingTokens.linen,
                          ),
                          color: isSelected
                              ? _OnboardingTokens.green
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 8,
                                color: _OnboardingTokens.off,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: _ContinueButton(
                label: 'Continue',
                onTap: controller.canContinueState ? controller.next : null,
                color: _OnboardingTokens.green,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ReasonsScreen extends StatelessWidget {
  const _ReasonsScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FlowScreen(
      step: 2,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Obx(() {
        final selectedReasons = controller.selectedReasons.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'What brought\nyou here?',
              style: textTheme.displayLarge?.copyWith(
                color: _OnboardingTokens.dark,
                fontSize: 50,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pick as many as you need',
              style: textTheme.bodySmall?.copyWith(
                color: _OnboardingTokens.dark.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 20),
            ...OnboardingController.reasons.map((reason) {
              final selected = selectedReasons.contains(reason);
              return InkWell(
                onTap: () => controller.toggleReason(reason),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reason,
                          style: textTheme.bodyLarge?.copyWith(
                            color: selected
                                ? _OnboardingTokens.green
                                : _OnboardingTokens.dark,
                            fontSize: 13,
                            letterSpacing: 0.05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: selected
                                ? _OnboardingTokens.green
                                : _OnboardingTokens.linen,
                          ),
                          color: selected
                              ? _OnboardingTokens.green
                              : Colors.transparent,
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 8,
                                color: _OnboardingTokens.off,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: _ContinueButton(
                label: 'Continue',
                onTap: selectedReasons.isNotEmpty ? controller.next : null,
                color: _OnboardingTokens.green,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PaywallScreen extends StatelessWidget {
  const _PaywallScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FlowScreen(
      step: 6,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      scrollable: true,
      child: Obx(() {
        final selectedPlan = controller.selectedPlan.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'Your week of wellness,\non us.',
              style: textTheme.displayLarge?.copyWith(
                color: _OnboardingTokens.dark,
                fontSize: 44,
                height: 1.04,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Take seven days to explore our tools and find what works for you',
              style: textTheme.bodySmall?.copyWith(
                color: _OnboardingTokens.dark.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 26),
            ...OnboardingController.paywallIncludes.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.check_rounded,
                        color: _OnboardingTokens.green,
                        size: 11,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: textTheme.titleMedium?.copyWith(
                              color: _OnboardingTokens.dark,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.body,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  _OnboardingTokens.dark.withValues(alpha: 0.7),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            ...OnboardingController.paywallPlans.map((plan) {
              final isSelected = selectedPlan == plan.key;
              return InkWell(
                onTap: () => controller.selectPlan(plan.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? _OnboardingTokens.green
                            : _OnboardingTokens.linen,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.label,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: isSelected
                                        ? _OnboardingTokens.green
                                        : _OnboardingTokens.dark,
                                    fontSize: 20,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (plan.note != null) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '· ${plan.note}',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: _OnboardingTokens.green,
                                      fontSize: 9,
                                      letterSpacing: 2.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              plan.meta,
                              style: textTheme.bodySmall?.copyWith(
                                color: _OnboardingTokens.dark
                                    .withValues(alpha: 0.7),
                                fontSize: 12,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        plan.price,
                        style: textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? _OnboardingTokens.green
                              : _OnboardingTokens.dark,
                          fontSize: 22,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            Text(
              switch (selectedPlan) {
                'year' =>
                  'Subscriptions renew automatically unless canceled in your Apple account settings.',
                'month' =>
                  'Subscriptions renew automatically unless canceled in your Apple account settings.',
                _ => 'One payment. Full access. No renewals.',
              },
              style: textTheme.bodySmall?.copyWith(
                color: _OnboardingTokens.dark.withValues(alpha: 0.62),
                fontSize: 11,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProviderButtonCustom(
              provider: _Provider.apple,
              onTap: controller.enterApp,
            ),
            // const SizedBox(height: AppSpacing.xs),
            // _ProviderButton(
            //   provider: _Provider.google,
            //   onTap: controller.next,
            // ),
            // const SizedBox(height: AppSpacing.xs),
            // _ProviderButton(
            //   provider: _Provider.email,
            //   onTap: controller.next,
            // ),
            // const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: _OnboardingTokens.linen, width: 0.5),
                ),
              ),
              child: TextButton(
                onPressed: controller.enterApp,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _OnboardingTokens.dark,
                ),
                child: Text(
                  'Not ready? Explore our free features',
                  style: textTheme.bodySmall?.copyWith(
                    color: _OnboardingTokens.dark,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationThickness: 0.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _IntentionScreen extends StatelessWidget {
  const _IntentionScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FlowScreen(
      step: 4,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          Text(
            'Finish the\nsentence.',
            style: textTheme.displayLarge?.copyWith(
              color: _OnboardingTokens.dark,
              fontSize: 50,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'In three months, I want to feel...',
            style: textTheme.displaySmall?.copyWith(
              color: _OnboardingTokens.dark,
              fontSize: 30,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w300,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _UnderlinedField(
            key: const ValueKey('onb-intention-field'),
            initialValue: controller.intention.value,
            onChanged: controller.setIntention,
            hintText: 'lighter, like I can finally catch my breath',
            autoFocus: true,
          ),
          const SizedBox(height: 14),
          Text(
            'No one else will read this. Just a private note for yourself.',
            style: textTheme.bodySmall?.copyWith(
              color: _OnboardingTokens.dark.withValues(alpha: 0.7),
              fontSize: 11,
              letterSpacing: 0.1,
              height: 1.5,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => _ContinueButton(
                label: 'Continue',
                onTap: controller.canContinueIntention ? controller.next : null,
                color: _OnboardingTokens.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameScreen extends StatelessWidget {
  const _NameScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _FlowScreen(
      step: 1,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          Text(
            'What is your\nname?',
            style: textTheme.displayLarge?.copyWith(
              color: _OnboardingTokens.dark,
              fontSize: 50,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'A first name, a nickname, or whatever feels most comfortable.',
            style: textTheme.bodySmall?.copyWith(
              color: _OnboardingTokens.dark.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 74),
          _UnderlinedField(
            key: const ValueKey('onb-name-field'),
            initialValue: controller.name.value,
            onChanged: controller.setName,
            hintText: 'Name or initials (optional)',
            autoFocus: true,
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: _ContinueButton(
              label: 'Continue',
              onTap: controller.next,
              color: _OnboardingTokens.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlimpseScreen extends StatelessWidget {
  const _GlimpseScreen({
    required this.controller,
  });

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final trimmedName = controller.name.value.trim();
    final firstName =
        trimmedName.isEmpty ? null : trimmedName.split(RegExp(r'\s+')).first;

    return _GlimpseBreath(
      firstName: firstName,
      onBack: controller.back,
      onNext: controller.next,
    );
  }
}

class _GlimpseBreath extends StatefulWidget {
  const _GlimpseBreath({
    required this.firstName,
    required this.onBack,
    required this.onNext,
  });

  final String? firstName;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  State<_GlimpseBreath> createState() => _GlimpseBreathState();
}

class _GlimpseBreathState extends State<_GlimpseBreath> {
  Timer? _timer;
  String _phase = 'inhale';

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() {
    _setPhase('inhale');
    _timer = Timer(const Duration(milliseconds: 3000), () {
      _setPhase('hold');
      _timer = Timer(const Duration(milliseconds: 2000), () {
        _setPhase('exhale');
        _timer = Timer(const Duration(milliseconds: 3000), _cycle);
      });
    });
  }

  void _setPhase(String phase) {
    if (!mounted) return;
    setState(() {
      _phase = phase;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleTween = switch (_phase) {
      'inhale' => Tween<double>(begin: 1.0, end: 1.08),
      'hold' => Tween<double>(begin: 1.08, end: 1.08),
      _ => Tween<double>(begin: 1.08, end: 1.0),
    };
    final duration = switch (_phase) {
      'inhale' => const Duration(milliseconds: 3000),
      'hold' => const Duration(milliseconds: 2000),
      _ => const Duration(milliseconds: 3000),
    };
    final phaseLabel = switch (_phase) {
      'inhale' => 'Breathe in',
      'hold' => 'Hold',
      _ => 'Breathe out',
    };
    final greetingName =
        widget.firstName != null && widget.firstName!.trim().isNotEmpty
            ? widget.firstName!.trim()
            : 'there';
    const green = Color(0xFF174F43);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.onboardingBreathBg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFEEF2F0).withValues(alpha: 0.32),
                      const Color(0xFFEEF2F0).withValues(alpha: 0.20),
                      const Color(0xFFEEF2F0).withValues(alpha: 0.08),
                      const Color(0xFFEEF2F0).withValues(alpha: 0),
                    ],
                    stops: const [0, 0.44, 0.72, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Positioned(
                      top: 18,
                      left: 20,
                      child: TextButton(
                        onPressed: widget.onBack,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: green.withValues(alpha: 0.92),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.jost(
                            color: green.withValues(alpha: 0.92),
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            height: 1,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.18,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            'Hi, $greetingName.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jost(
                              color: green,
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              height: 1.08,
                              letterSpacing: 2.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Let’s begin with one small breath.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jost(
                              color: green.withValues(alpha: 0.92),
                              fontSize: 23,
                              fontWeight: FontWeight.w300,
                              height: 1.25,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.42,
                      left: 0,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('breath-scale-$_phase'),
                        tween: scaleTween,
                        duration: duration,
                        curve: Curves.easeInOutCubic,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Text(
                            phaseLabel,
                            key: ValueKey(phaseLabel),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jost(
                              color: green,
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              height: 1,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: constraints.maxHeight * 0.67,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: 180,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: widget.onNext,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.0),
                                width: 1.35,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                            ),
                            child: Text(
                              'Begin',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.jost(
                                color: green,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                height: 1,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UnderlinedField extends StatelessWidget {
  const _UnderlinedField({
    required this.initialValue,
    required this.onChanged,
    required this.hintText,
    this.autoFocus = false,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      autofocus: autoFocus,
      style: textTheme.bodyLarge?.copyWith(
        color: _OnboardingTokens.dark,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: _OnboardingTokens.taupe.withValues(alpha: 0.75),
          fontSize: 16,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _OnboardingTokens.linen, width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _OnboardingTokens.green, width: 0.8),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        foregroundColor: color,
        disabledForegroundColor: color.withValues(alpha: 0.3),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              letterSpacing: 0.05,
              fontWeight: FontWeight.w500,
              color: onTap == null ? color.withValues(alpha: 0.3) : color,
            ),
      ),
    );
  }
}

enum _Provider {
  apple,
  google,
  email,
}

class _ProviderButtonCustom extends StatelessWidget {
  const _ProviderButtonCustom({
    required this.provider,
    required this.onTap,
  });

  final _Provider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isApple = provider == _Provider.apple;
    final label = switch (provider) {
      _Provider.apple => 'Continue',
      _Provider.google => 'Continue with Google',
      _Provider.email => 'Continue with email',
    };
    final foreground = isApple ? _OnboardingTokens.off : _OnboardingTokens.dark;
    final background = isApple ? _OnboardingTokens.dark : _OnboardingTokens.off;
    final borderColor =
        isApple ? _OnboardingTokens.dark : _OnboardingTokens.linen;

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground,
            backgroundColor: AppColors.primary,
            side: BorderSide(color: borderColor, width: 0.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _ProviderGlyph(provider: provider, color: foreground),
              // const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.05,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.provider,
    required this.onTap,
  });

  final _Provider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isApple = provider == _Provider.apple;
    final label = switch (provider) {
      _Provider.apple => 'Continue',
      _Provider.google => 'Continue with Google',
      _Provider.email => 'Continue with email',
    };
    final foreground = isApple ? _OnboardingTokens.off : _OnboardingTokens.dark;
    final background = isApple ? _OnboardingTokens.dark : _OnboardingTokens.off;
    final borderColor =
        isApple ? _OnboardingTokens.dark : _OnboardingTokens.linen;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          side: BorderSide(color: borderColor, width: 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // _ProviderGlyph(provider: provider, color: foreground),
            // const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.05,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatercolorBackdrop extends StatelessWidget {
  const _WatercolorBackdrop({
    required this.accent,
    this.opacity = 0.1,
  });

  final Color accent;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.32, -0.22),
                  radius: 1.02,
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    accent.withValues(alpha: 0.28),
                    accent.withValues(alpha: 0.48),
                  ],
                  stops: const [0.0, 0.58, 1.0],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.7, 0.75),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
