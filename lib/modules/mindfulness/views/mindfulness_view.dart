import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_chip.dart';
import '../../../widgets/premium_lock_overlay.dart';
import '../controllers/mindfulness_controller.dart';

class MindfulnessView extends GetView<MindfulnessController> {
  const MindfulnessView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(AppIcons.back),
            ),
            Text('Mindfulness', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Meditation, ASMR, and visualizations for regulated moments.',
                style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(
                  controller.tabs.length,
                  (index) => AppTagChip(
                    label: controller.tabs[index],
                    selected: controller.selectedTab.value == index,
                    onTap: () => controller.selectTab(index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2E9DE), Color(0xFFFBF6F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Featured session', style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Quiet the room inside you',
                      style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A guided session for the moments when everything feels too loud.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(AppIcons.play, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('10 min session', style: textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(
              () => Column(
                children: controller.sessions
                    .map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SessionCard(
                            session: session,
                            onTap: () => controller.openSession(session)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final MindfulnessSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppCard(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: session.color.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(AppIcons.play, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(session.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text('${session.type} • ${session.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        PremiumLockOverlay(show: session.isPremium),
      ],
    );
  }
}
