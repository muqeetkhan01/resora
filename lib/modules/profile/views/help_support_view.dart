import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const items = [
      (
        'frequently asked questions',
        'Browse answers to the most common questions about Resora.',
      ),
      (
        'contact us',
        'Reach the Resora team directly. We aim to respond within 24 hours.',
      ),
      (
        'send feedback',
        'Share a thought, flag something, or tell us what you love.',
      ),
      (
        'report a bug',
        'Something not working right? Let us know.',
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
              const CenteredBackHeader(title: 'help & support'),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'We are here if you need us. Everything below goes directly to the Resora team.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...items.map(
                (item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        item.$1,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.$2, style: textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('version 2.1.0 · the resora team',
                  style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
