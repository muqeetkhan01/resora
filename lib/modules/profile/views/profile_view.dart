import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/app_models.dart';
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
              Text(session.displayName, style: textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text('free membership', style: textTheme.bodySmall),
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
                  style:
                      textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                () => SwitchListTile.adaptive(
                  value: controller.journalLockEnabled.value,
                  onChanged: controller.toggleJournalLock,
                  contentPadding: EdgeInsets.zero,
                  title: Text('journal lock', style: textTheme.titleMedium),
                  subtitle:
                      Text('pin or biometrics', style: textTheme.bodySmall),
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),
              ...controller.options.map(
                (option) => _OptionRow(
                  option: option,
                  onTap: () => controller.openOption(option),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          title: Text(option.label,
              style: Theme.of(context).textTheme.titleMedium),
          trailing: option.trailing != null
              ? Text(option.trailing!,
                  style: Theme.of(context).textTheme.bodySmall)
              : const Icon(
                  AppIcons.forward,
                  color: AppColors.terracotta,
                  size: 15,
                ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
