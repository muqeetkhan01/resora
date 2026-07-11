import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      0 => _CoverScreen(onNext: controller.next),
      1 => _StateScreen(controller: controller),
      2 => _ReasonsScreen(controller: controller),
      3 => _PaywallScreen(controller: controller),
      4 => _IntentionScreen(controller: controller),
      5 => _NameScreen(controller: controller),
      _ => _GlimpseScreen(controller: controller),
    };
  }
}

class _OnboardingTokens {
  static const Color green = Color(0xFF145C4F);
  static const Color off = Color(0xFFFAFBF9);
  static const Color dark = Color(0xFF4A342B);
  static const Color stone = Color(0xFFE3DED5);
  static const Color linen = Color(0xFFD7CFC2);
  static const Color taupe = Color(0xFF8C7A6D);
}

class _FlowScreen extends StatelessWidget {
  const _FlowScreen({
    required this.child,
    this.step,
    this.total,
    this.onBack,
    this.background = _OnboardingTokens.off,
    this.ink = _OnboardingTokens.dark,
    this.scrollable = false,
  });

  final Widget child;
  final int? step;
  final int? total;
  final VoidCallback? onBack;
  final Color background;
  final Color ink;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final muted = ink == _OnboardingTokens.off
        ? _OnboardingTokens.off.withOpacity(0.6)
        : _OnboardingTokens.taupe;
    final track = ink == _OnboardingTokens.off
        ? _OnboardingTokens.off.withOpacity(0.22)
        : _OnboardingTokens.stone;
    final progressColor = ink == _OnboardingTokens.off
        ? _OnboardingTokens.off
        : _OnboardingTokens.green;

    return DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _WatercolorBackdrop(
            accent: ink == _OnboardingTokens.off
                ? _OnboardingTokens.green
                : _OnboardingTokens.dark,
            opacity: ink == _OnboardingTokens.off ? 0.18 : 0.08,
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
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(color: _OnboardingTokens.green),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _WatercolorBackdrop(
            accent: _OnboardingTokens.green,
            opacity: 0.22,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 80, 32, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resora',
                    style: textTheme.displayMedium?.copyWith(
                      color: _OnboardingTokens.off,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Life gets\nbetter\nwhen you do.',
                    style: textTheme.displayLarge?.copyWith(
                      color: _OnboardingTokens.off,
                      fontSize: 68,
                      fontWeight: FontWeight.w300,
                      height: 0.98,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 136,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: onNext,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _OnboardingTokens.off,
                          side: const BorderSide(
                            color: _OnboardingTokens.off,
                            width: 0.5,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                        ),
                        child: Text(
                          'Begin',
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge?.copyWith(
                            color: _OnboardingTokens.off,
                            fontSize: 13,
                            letterSpacing: 0.05,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
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
      step: 1,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Obx(() {
        final selected = controller.selectedState.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Text(
              'Where are\nyou right now?',
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
                'No wrong answer. This sets the tone of your first reset.',
                style: textTheme.bodySmall?.copyWith(
                  color: _OnboardingTokens.taupe,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ...OnboardingController.states.asMap().entries.map((entry) {
              final item = entry.value;
              final isSelected = selected == item.key;
              return InkWell(
                onTap: () => controller.setStateValue(item.key),
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
                      if (isSelected)
                        const Icon(
                          Icons.check_rounded,
                          color: _OnboardingTokens.green,
                          size: 14,
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
              'Pick a few.',
              style: textTheme.bodySmall?.copyWith(
                color: _OnboardingTokens.taupe,
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
            Row(
              children: [
                TextButton(
                  onPressed: controller.next,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: _OnboardingTokens.taupe,
                  ),
                  child: Text(
                    'Skip',
                    style: textTheme.bodySmall?.copyWith(
                      color: _OnboardingTokens.taupe,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationThickness: 0.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                _ContinueButton(
                  label: selectedReasons.isNotEmpty
                      ? 'Continue (${selectedReasons.length})'
                      : 'Continue',
                  onTap: selectedReasons.isNotEmpty ? controller.next : null,
                  color: _OnboardingTokens.green,
                ),
              ],
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
      step: 3,
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
              'A modern space for your mental wellness. Because life gets better when you do.',
              style: textTheme.bodySmall?.copyWith(
                color: _OnboardingTokens.taupe,
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
                              color: _OnboardingTokens.taupe,
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
                                color: _OnboardingTokens.taupe,
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
                color: _OnboardingTokens.taupe,
                fontSize: 11,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProviderButton(
              provider: _Provider.apple,
              onTap: controller.next,
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
                onPressed: controller.next,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _OnboardingTokens.taupe,
                ),
                child: Text(
                  'Not now — start a limited free plan',
                  style: textTheme.bodySmall?.copyWith(
                    color: _OnboardingTokens.taupe,
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
              color: _OnboardingTokens.taupe,
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
            hintText: 'Less braced, more here',
            autoFocus: true,
          ),
          const SizedBox(height: 14),
          Text(
            'A few words is plenty. No one else will read this.',
            style: textTheme.bodySmall?.copyWith(
              color: _OnboardingTokens.taupe,
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
      step: 5,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 36),
          Text(
            'What is\nyour name?',
            style: textTheme.displayLarge?.copyWith(
              color: _OnboardingTokens.dark,
              fontSize: 50,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'First name, a nickname, or nothing at all.',
            style: textTheme.bodySmall?.copyWith(
              color: _OnboardingTokens.taupe,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 44),
          _UnderlinedField(
            key: const ValueKey('onb-name-field'),
            initialValue: controller.name.value,
            onChanged: controller.setName,
            hintText: 'Your name (optional)',
            autoFocus: true,
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed: controller.next,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _OnboardingTokens.taupe,
                ),
                child: Text(
                  'Skip',
                  style: textTheme.bodySmall?.copyWith(
                    color: _OnboardingTokens.taupe,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationThickness: 0.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              _ContinueButton(
                label: 'Continue',
                onTap: controller.next,
                color: _OnboardingTokens.green,
              ),
            ],
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

    return _FlowScreen(
      step: 6,
      total: OnboardingController.totalStepsAfterCover,
      onBack: controller.back,
      background: _OnboardingTokens.green,
      ink: _OnboardingTokens.off,
      child: _GlimpseBreath(
        firstName: firstName,
        onEnterApp: controller.enterApp,
      ),
    );
  }
}

class _GlimpseBreath extends StatefulWidget {
  const _GlimpseBreath({
    required this.firstName,
    required this.onEnterApp,
  });

  final String? firstName;
  final VoidCallback onEnterApp;

  @override
  State<_GlimpseBreath> createState() => _GlimpseBreathState();
}

class _GlimpseBreathState extends State<_GlimpseBreath> {
  Timer? _timer;
  String _phase = 'inhale';
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _cycle();
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _revealed = true);
    });
  }

  void _cycle() {
    _setPhase('inhale');
    _timer = Timer(const Duration(milliseconds: 4000), () {
      _setPhase('hold');
      _timer = Timer(const Duration(milliseconds: 2000), () {
        _setPhase('exhale');
        _timer = Timer(const Duration(milliseconds: 6000), _cycle);
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
    final textTheme = Theme.of(context).textTheme;

    final scale = switch (_phase) {
      'inhale' => 1.0,
      'hold' => 1.0,
      _ => 0.55,
    };
    final duration = switch (_phase) {
      'inhale' => const Duration(milliseconds: 4000),
      'hold' => const Duration(milliseconds: 2000),
      _ => const Duration(milliseconds: 6000),
    };
    final phaseLabel = switch (_phase) {
      'inhale' => 'Breathe in',
      'hold' => 'Hold',
      _ => 'Breathe out',
    };

    return Column(
      children: [
        const SizedBox(height: 72),
        // Text(
        //   widget.firstName != null && widget.firstName!.trim().isNotEmpty
        //       ? 'A glimpse, for ${widget.firstName}'
        //       : 'A glimpse',
        //   style: textTheme.labelMedium?.copyWith(
        //     color: _OnboardingTokens.off.withOpacity(0.7),
        //     letterSpacing: 3.0,
        //     fontSize: 10,
        //     fontWeight: FontWeight.w400,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        const SizedBox(height: 56),
        Column(
          children: [
            AnimatedScale(
              scale: scale,
              duration: duration,
              curve: Curves.easeInOutCubic,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _OnboardingTokens.off.withOpacity(0.9),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              phaseLabel,
              style: textTheme.labelMedium?.copyWith(
                color: _OnboardingTokens.off.withOpacity(0.7),
                letterSpacing: 3.0,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 120),
        AnimatedOpacity(
          opacity: _revealed ? 1 : 0,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: _revealed ? Offset.zero : const Offset(0, 0.05),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            child: Column(
              children: [
                Text(
                  'Life gets better when you do${widget.firstName != null && widget.firstName!.trim().isNotEmpty ? ', ${widget.firstName}' : ''}.',
                  style: textTheme.displaySmall?.copyWith(
                    color: _OnboardingTokens.off,
                    fontSize: 42,
                    height: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                // Text(
                //   'This is where that begins.',
                //   style: textTheme.displaySmall?.copyWith(
                //     color: _OnboardingTokens.off.withOpacity(0.78),
                //     fontSize: 28,
                //     fontStyle: FontStyle.normal,
                //     height: 1.35,
                //     fontWeight: FontWeight.w300,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 136,
          height: 56,
          child: OutlinedButton(
            onPressed: widget.onEnterApp,
            style: OutlinedButton.styleFrom(
              foregroundColor: _OnboardingTokens.off,
              side: const BorderSide(
                color: _OnboardingTokens.off,
                width: 0.5,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
            ),
            child: Text(
              'Continue',
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                color: _OnboardingTokens.off,
                fontSize: 13,
                letterSpacing: 0.05,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xs + 30),
      ],
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
          color: _OnboardingTokens.taupe.withOpacity(0.75),
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
        disabledForegroundColor: color.withOpacity(0.3),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              letterSpacing: 0.05,
              fontWeight: FontWeight.w500,
              color: onTap == null ? color.withOpacity(0.3) : color,
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
                    Colors.white.withOpacity(0.8),
                    accent.withOpacity(0.28),
                    accent.withOpacity(0.48),
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
                  color: accent.withOpacity(0.22),
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
