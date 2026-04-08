import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/centered_back_header.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Obx(
        () => SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CenteredBackHeader(title: 'edit profile'),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'name',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller.nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'email',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'email'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Changing your email sends a verification link before it updates.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: controller.isSaving.value ? 'saving...' : 'save changes',
                style: AppButtonStyle.secondary,
                onPressed:
                    controller.isSaving.value ? null : controller.saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
