import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/controllers/app_session_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final session = Get.find<AppSessionController>();

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
              const CenteredBackHeader(title: 'settings'),
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.displayName, style: textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      session.email ?? 'No email on file',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${session.authProviderLabel} account',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: controller.openEditProfile,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'edit profile',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'preferences',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.placeholder,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              Obx(
                () => SwitchListTile.adaptive(
                  value: controller.affirmationsEnabled.value,
                  onChanged: controller.toggleAffirmations,
                  contentPadding: EdgeInsets.zero,
                  title: Text('affirmations', style: textTheme.titleMedium),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),
              Obx(
                () => _OptionRow(
                  label: 'journal lock',
                  subtitle: 'pin or biometrics',
                  trailingText:
                      controller.journalLockEnabled.value ? 'On' : 'Off',
                  onTap: controller.openJournalLock,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'account',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.placeholder,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              _OptionRow(
                label: 'subscription',
                onTap: controller.openSubscription,
              ),
              _OptionRow(
                label: 'privacy policy',
                onTap: controller.openPrivacyPolicy,
              ),
              _OptionRow(
                label: 'help & support',
                onTap: controller.openHelpSupport,
              ),
              _OptionRow(
                label: 'log out',
                danger: true,
                onTap: () => _showLogoutSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  color: AppColors.line,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('log out?', style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You can always log back in. Your journal and progress will stay here.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await controller.signOut();
                  },
                  child: Text(
                    'log out',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'cancel',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailingText,
    this.danger = false,
  });

  final String label;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              color: danger ? AppColors.terracotta : AppColors.primary,
            ),
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: textTheme.bodySmall),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(trailingText!, style: textTheme.bodySmall),
                ),
              const Icon(
                AppIcons.forward,
                color: AppColors.terracotta,
                size: 15,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
