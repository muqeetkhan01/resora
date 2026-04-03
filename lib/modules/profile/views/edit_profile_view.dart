import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

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
              icon: const Icon(AppIcons.back, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('edit profile', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(hintText: 'name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'email'),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: 'save changes',
              style: AppButtonStyle.secondary,
              onPressed: controller.saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
