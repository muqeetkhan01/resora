import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FrostedPill(child: Text('Saturday ritual')),
                    const SizedBox(height: AppSpacing.md),
                    Text('Welcome back, ${MockContent.userName}',
                        style: textTheme.displayMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'What would support you most today?',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.shell,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFF2ECE4), Color(0xFFE8E3D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calm status', style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('Your energy looks tender today.',
                    style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A 5-minute pause and a gentle reflection could help you feel more settled before the evening rush.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                const Row(
                  children: [
                    _MetricPill(label: 'Grounded', value: '64%'),
                    SizedBox(width: AppSpacing.sm),
                    _MetricPill(label: 'Breath', value: '2 min'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Quick access',
            subtitle: 'Small rituals and support, right where you need them',
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 420 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.quickActions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 132,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                ),
                itemBuilder: (context, index) {
                  final item = controller.quickActions[index];
                  return _QuickActionCard(
                    item: item,
                    onTap: () => controller.openQuickAction(item),
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Featured premium',
            subtitle: 'Unlock deeper support designed for hard seasons',
            actionLabel: 'See plans',
            onAction: controller.openPremium,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            gradient: AppColors.premiumGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resora Premium',
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Expert answers, premium visualizations, deeper affirmation packs, and personalized calm pathways.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: controller.openPremium,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Unlock premium',
                      style:
                          textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Daily reminder'),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Text(
              controller.quote,
              style: textTheme.headlineMedium?.copyWith(height: 1.3),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Recently used'),
          const SizedBox(height: AppSpacing.md),
          ...controller.recentItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.cardStrong,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.play_arrow_rounded),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(item, style: textTheme.titleMedium)),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.item,
    required this.onTap,
  });

  final QuickActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      color: AppColors.shell.withOpacity(0.94),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppColors.ink, size: 21),
              ),
              const Spacer(),
              _QuickActionPremiumTag(show: item.premium),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _QuickActionPremiumTag extends StatelessWidget {
  const _QuickActionPremiumTag({required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox(width: 42, height: 24);
    }

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 11,
            color: AppColors.ink,
          ),
          const SizedBox(width: 4),
          Text(
            'Pro',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
