import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 34),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${MockContent.userName} Rahman',
                          style: textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      Text('Gentle routines, healing, mindful parenting',
                          style: textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8D5B8), Color(0xFFC89A60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium preview',
                  style: textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Unlock deeper guidance and exclusive rituals.',
                  style:
                      textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'View subscription',
                  style: AppButtonStyle.secondary,
                  onPressed: controller.openPremium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              children: controller.options.map((option) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(option.icon),
                  title: Text(option.label),
                  trailing: option.trailing != null
                      ? Text(option.trailing!, style: textTheme.bodySmall)
                      : const Icon(Icons.chevron_right_rounded),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
