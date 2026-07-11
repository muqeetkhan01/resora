import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_close_button.dart';
import '../controllers/profile_controller.dart';
import 'widgets/settings_flow_widgets.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AppSessionController>();

    return SettingsPageFrame(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCloseButton(onPressed: Get.back),
                const SizedBox(height: 78),
                // Text('settings',
                //     style: SettingsFlowText.display(context, size: 36)),
                // const SizedBox(height: 6),
                Text(session.displayName,
                    style: SettingsFlowText.title(context, size: 15)),
                const SizedBox(height: 2),
                Text('${session.authProviderLabel} Account',
                    style: SettingsFlowText.body(context, size: 11)),
                const SizedBox(height: 8),
                SettingsUnderlineButton(
                  label: 'Edit Profile',
                  color: SettingsFlowColors.terracotta,
                  onTap: controller.openEditProfile,
                ),
              ],
            ),
          ),
        ),
        const SectionLabel('Your Space', isColorGreen: true),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'Membership',
          subtitle: 'View your plan and manage your access.',
          onTap: controller.openSubscription,
        ),
        const SettingsRule(horizontal: 0),
        const SectionLabel('Support & Privacy', isColorGreen: true),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'Help & Support',
          subtitle: 'Get help, send feedback, or report an issue.',
          onTap: controller.openHelpSupport,
        ),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'Privacy Policy',
          subtitle: 'Learn how Resora handles your information.',
          onTap: controller.openPrivacyPolicy,
        ),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'Terms of Use',
          subtitle: 'Review Resora\'s terms and safety information.',
          onTap: controller.openTermsOfUse,
        ),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'Delete Account',
          subtitle: 'Request deletion of your account and saved data.',
          onTap: controller.openDeleteAccount,
        ),
        const SettingsRule(horizontal: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: SettingsUnderlineButton(
            label: 'Log Out',
            color: SettingsFlowColors.terracotta,
            onTap: () => _showLogoutSheet(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: Get.height * 0.2),
                Text(
                  'r e s o r a',
                  style: SettingsFlowText.display(context, size: 18).copyWith(
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Version 2.1.0',
                    style: SettingsFlowText.caps(context, size: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutSheet(BuildContext context) async {
    final confirmed = await showSettingsConfirm(
      context,
      title: 'Log out?',
      message: 'You can always log back in. Your data will be waiting for you.',
      confirmLabel: 'Log Out',
    );
    if (confirmed) {
      await controller.signOut();
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
