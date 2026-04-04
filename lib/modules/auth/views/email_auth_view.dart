import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/app_button.dart';
import '../controllers/email_auth_controller.dart';

class EmailAuthView extends GetView<EmailAuthController> {
  const EmailAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBackground(
      child: Obx(
        () => SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon:
                    const Icon(Icons.arrow_back_ios, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text('continue', style: textTheme.headlineMedium),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'email',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'amber@resora.com'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'password',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller.passwordController,
                obscureText: controller.obscurePassword.value,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    onPressed: controller.togglePassword,
                    icon: Icon(
                      controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
              if (!controller.isSignIn.value) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'confirm password',
                  style:
                      textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: controller.obscureConfirmPassword.value,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      onPressed: controller.toggleConfirmPassword,
                      icon: Icon(
                        controller.obscureConfirmPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: controller.isSignIn.value ? 'sign in' : 'continue',
                style: AppButtonStyle.secondary,
                onPressed: controller.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
