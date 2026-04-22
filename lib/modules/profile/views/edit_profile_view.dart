import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CenteredBackHeader(title: 'edit profile'),
                const SizedBox(height: AppSpacing.xl),
                Text('display name', style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: controller.nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'your name'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('email', style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: controller.canEditEmail,
                  decoration: const InputDecoration(hintText: 'you@email.com'),
                ),
                if (!controller.canEditEmail) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Managed by your sign in provider. It cannot be changed here.',
                    style: textTheme.bodySmall,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Changing your email sends a verification link before it updates.',
                    style: textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveProfile,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(
                      controller.isSaving.value ? 'saving...' : 'save changes',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'delete account',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.terracotta,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
