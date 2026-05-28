import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_controller.dart';
import 'widgets/settings_flow_widgets.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsFlowColors.offWhite,
      body: SafeArea(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsTopBack(title: ''),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Text('edit profile',
                    style: SettingsFlowText.display(context, size: 32)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('display name',
                        style: SettingsFlowText.caps(context, size: 9)),
                    const SizedBox(height: 8),
                    SettingsTextField(
                      controller: controller.nameController,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 28),
                    Text('email',
                        style: SettingsFlowText.caps(context, size: 9)),
                    const SizedBox(height: 8),
                    SettingsTextField(
                      controller: controller.emailController,
                      enabled: controller.canEditEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.canEditEmail
                          ? 'Changing your email sends a verification link before it updates.'
                          : 'Managed by your sign-in provider.\nIt cannot be changed here.',
                      style: SettingsFlowText.body(context, size: 11),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsUnderlineButton(
                      label: 'delete account',
                      color: SettingsFlowColors.terracotta,
                      onTap: () => _confirmDelete(context),
                    ),
                    SettingsUnderlineButton(
                      label: controller.isSaving.value
                          ? 'saving...'
                          : 'save changes',
                      color: SettingsFlowColors.warmDark,
                      onTap: controller.isSaving.value
                          ? () {}
                          : controller.saveProfile,
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

  Future<void> _confirmDelete(BuildContext context) async {
    await showSettingsConfirm(
      context,
      title: 'Delete your account?',
      message:
          'This is permanent. All your journal entries, resets, and progress will be removed and cannot be recovered.',
      confirmLabel: 'delete account',
      destructive: true,
    );
  }
}
