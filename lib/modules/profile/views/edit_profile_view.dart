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
              const SizedBox(height: 58),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Text('Edit Profile',
                    style: SettingsFlowText.display(context, size: 32)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Display Name',
                        style: SettingsFlowText.caps(context,
                            size: 9, color: SettingsFlowColors.forestGreen)),
                    const SizedBox(height: 8),
                    SettingsTextField(
                      controller: controller.nameController,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 28),
                    Text('Email',
                        style: SettingsFlowText.caps(context,
                            size: 9, color: SettingsFlowColors.forestGreen)),
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
              // const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsUnderlineButton(
                      label: 'Delete Account',
                      color: SettingsFlowColors.terracotta,
                      onTap: () => _confirmDelete(context),
                    ),
                    SettingsUnderlineButton(
                      label: controller.isSaving.value
                          ? 'Saving...'
                          : 'Save Changes',
                      color: SettingsFlowColors.terracotta,
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
      confirmLabel: 'Delete Account',
      destructive: true,
    );
  }
}
