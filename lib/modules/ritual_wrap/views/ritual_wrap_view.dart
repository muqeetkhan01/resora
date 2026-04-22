import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../models/ritual_wrap_args.dart';

class RitualWrapView extends StatelessWidget {
  const RitualWrapView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = RitualWrapArgs.from(Get.arguments);
    final config = _featureContent(args.feature);
    final isEntry = args.isEntry;
    final darkMode = !isEntry && config.exitDark;

    final background = darkMode ? AppColors.primary : AppColors.canvas;
    final titleColor = darkMode ? AppColors.white : AppColors.primary;
    final subtitleColor =
        darkMode ? AppColors.white.withOpacity(0.72) : AppColors.placeholder;
    final lineColor = darkMode
        ? AppColors.white.withOpacity(0.34)
        : AppColors.terracotta.withOpacity(0.7);

    final label = isEntry ? config.entryLabel : config.exitLabel;
    final title = isEntry ? config.entryTitle : config.exitTitle;
    final subtitle = isEntry ? config.entrySubtitle : config.exitSubtitle;
    final cta = isEntry ? config.entryAction : config.exitAction;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 1,
                        height: 40,
                        color: lineColor,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: lineColor,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: titleColor,
                              fontSize: 34,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: subtitleColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 4),
              TextButton(
                onPressed: () => _continue(args),
                child: Text(
                  cta,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        letterSpacing: 1.4,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  void _continue(RitualWrapArgs args) {
    if (args.nextRoute != null) {
      Get.offNamed(args.nextRoute!, arguments: args.nextArguments);
      return;
    }

    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.dashboard);
  }

  _FeatureContent _featureContent(String feature) {
    switch (feature) {
      case RitualWrapFeature.meditation:
        return const _FeatureContent(
          entryLabel: 'GENTLE RESET',
          entryTitle: 'Settle in.',
          entrySubtitle: 'You do not need to bring anything with you.',
          entryAction: 'begin',
          exitLabel: 'GENTLE RESET',
          exitTitle: 'You came back\nto yourself.',
          exitSubtitle: 'Carry this pace with you into what comes next.',
          exitAction: 'continue',
          exitDark: true,
        );
      case RitualWrapFeature.asmr:
        return const _FeatureContent(
          entryLabel: 'QUIET THE NOISE',
          entryTitle: 'Let the outside\nfall away.',
          entrySubtitle: 'Headphones on if you can. Just listen.',
          entryAction: 'begin',
          exitLabel: 'QUIET THE NOISE',
          exitTitle: 'Rest well.',
          exitSubtitle: 'You gave yourself this pause.',
          exitAction: 'continue',
          exitDark: true,
        );
      case RitualWrapFeature.visualization:
        return const _FeatureContent(
          entryLabel: 'REHEARSE THE MOMENT',
          entryTitle: 'Close your eyes.\nTake one breath.',
          entrySubtitle: 'We start with one clear line at a time.',
          entryAction: 'begin',
          exitLabel: 'REHEARSE THE MOMENT',
          exitTitle: 'Bring it\nwith you.',
          exitSubtitle: 'That steadier version of you is already real.',
          exitAction: 'continue',
          exitDark: true,
        );
      case RitualWrapFeature.normal:
        return const _FeatureContent(
          entryLabel: 'IS THIS NORMAL',
          entryTitle: 'Ask what you have\nnot said out loud.',
          entrySubtitle: 'Your question belongs here.',
          entryAction: 'continue',
          exitLabel: 'IS THIS NORMAL',
          exitTitle: 'Someone heard you.',
          exitSubtitle: 'You were right to ask.',
          exitAction: 'return',
        );
      case RitualWrapFeature.talk:
        return const _FeatureContent(
          entryLabel: 'TALK TO RESORA',
          entryTitle: 'What is on your\nmind today?',
          entrySubtitle: 'One clear sentence is enough to start.',
          entryAction: 'begin',
          exitLabel: 'TALK TO RESORA',
          exitTitle: 'Come back when\nyou are ready.',
          exitSubtitle: 'The conversation can stay simple and honest.',
          exitAction: 'close session',
        );
      case RitualWrapFeature.journal:
      default:
        return const _FeatureContent(
          entryLabel: 'JOURNAL',
          entryTitle: 'What are you\ncarrying right now?',
          entrySubtitle: 'Take your time. Begin when you are ready.',
          entryAction: 'begin',
          exitLabel: 'JOURNAL',
          exitTitle: 'You stayed.',
          exitSubtitle: 'That reflection is yours now.',
          exitAction: 'return',
        );
    }
  }
}

class _FeatureContent {
  const _FeatureContent({
    required this.entryLabel,
    required this.entryTitle,
    required this.entrySubtitle,
    required this.entryAction,
    required this.exitLabel,
    required this.exitTitle,
    required this.exitSubtitle,
    required this.exitAction,
    this.exitDark = false,
  });

  final String entryLabel;
  final String entryTitle;
  final String entrySubtitle;
  final String entryAction;
  final String exitLabel;
  final String exitTitle;
  final String exitSubtitle;
  final String exitAction;
  final bool exitDark;
}
