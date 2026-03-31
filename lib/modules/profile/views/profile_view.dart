import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/mock/mock_content.dart';
import '../../../data/models/app_models.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(AppIcons.close, color: AppColors.primary),
              ),
              Text('profile', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Icon(AppIcons.account, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockContent.userName,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Free membership', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    AppButton(
                      label: 'Edit',
                      style: AppButtonStyle.secondary,
                      expanded: false,
                      onPressed: controller.openEditProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('premium', style: textTheme.labelLarge?.copyWith(color: AppColors.terracotta)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Unlock full audio, unlimited talk support, deeper journal tools, and premium content.',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.warmDark),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'View plans',
                      onPressed: controller.openPremium,
                      expanded: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsCard(
                title: 'preferences',
                child: Column(
                  children: [
                    Obx(
                      () => _SwitchRow(
                        label: 'Affirmations',
                        subtitle: 'Morning delivery',
                        value: controller.affirmationsEnabled.value,
                        onChanged: controller.toggleAffirmations,
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => _SwitchRow(
                        label: 'Dark mode',
                        subtitle: 'Off',
                        value: controller.darkModeEnabled.value,
                        onChanged: controller.toggleDarkMode,
                      ),
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => _SwitchRow(
                        label: 'Journal lock',
                        subtitle: 'PIN or biometrics',
                        value: controller.journalLockEnabled.value,
                        onChanged: controller.toggleJournalLock,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsCard(
                title: 'account',
                child: Column(
                  children: controller.options.map((option) {
                    return Column(
                      children: [
                        _OptionRow(
                          option: option,
                          onTap: () => controller.openOption(option),
                        ),
                        if (option != controller.options.last) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsCard(
                title: 'explore',
                child: Column(
                  children: [
                    _OptionRow(
                      option: const ProfileOption(
                        label: 'Mindfulness library',
                        icon: AppIcons.play,
                      ),
                      onTap: controller.openMindfulness,
                    ),
                    const Divider(height: 1),
                    _OptionRow(
                      option: const ProfileOption(
                        label: 'Community preview',
                        icon: AppIcons.questions,
                      ),
                      onTap: controller.openCommunity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      activeColor: AppColors.primary,
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.onTap,
  });

  final ProfileOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(option.icon, color: AppColors.primary, size: 20),
      title: Text(option.label, style: Theme.of(context).textTheme.titleMedium),
      trailing: option.trailing != null
          ? Text(option.trailing!, style: Theme.of(context).textTheme.bodySmall)
          : const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
    );
  }
}
