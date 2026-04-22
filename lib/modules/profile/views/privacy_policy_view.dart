import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const sections = [
      (
        'what we collect',
        'We collect only what is needed to deliver your experience: account details, usage patterns, and any content you choose to save. We do not sell your data.',
      ),
      (
        'your journal',
        'Journal entries are stored securely and are never used for advertising or shared with third parties.',
      ),
      (
        'how we use your data',
        'Your data helps personalize your experience, deliver affirmations, and improve Resora over time.',
      ),
      (
        'third parties',
        'We work with trusted partners for authentication, payments, and analytics. None receive your private journal content.',
      ),
      (
        'your rights',
        'You can request a copy of your data, correct inaccuracies, or delete your account at any time from Settings.',
      ),
      (
        'contact',
        'Questions about privacy? Reach the team at privacy@resora.app.',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'privacy policy'),
              const SizedBox(height: AppSpacing.lg),
              Text('last updated January 2025', style: textTheme.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              ...sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.$1,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(section.$2, style: textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
