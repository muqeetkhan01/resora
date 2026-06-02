import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';
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
                InkWell(
                  onTap: Get.back,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: SettingsFlowColors.terracotta,
                  ),
                ),
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
                  label: 'edit profile',
                  color: SettingsFlowColors.terracotta,
                  onTap: controller.openEditProfile,
                ),
              ],
            ),
          ),
        ),
        const SectionLabel('your space', isColorGreen: true),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'journal lock',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SettingsToggle(
              //   value: controller.journalLockEnabled.value,
              //   onChanged: (value) {
              //     if (value) {
              //       controller.openJournalLock();
              //     } else {
              //       controller.toggleJournalLock(false);
              //     }
              //   },
              // ),
              // const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  controller.openJournalLock();
                },
                child: Text(
                  '›',
                  style: SettingsFlowText.title(context, size: 18)
                      .copyWith(color: SettingsFlowColors.terracotta),
                ),
              ),
            ],
          ),
          onTap: controller.openJournalLock,
        ),
        const SettingsRule(horizontal: 0),
        const SectionLabel('membership', isColorGreen: true),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'membership',
          subtitle: 'Elevate your experience.',
          onTap: controller.openSubscription,
        ),
        const SettingsRule(horizontal: 0),
        const SectionLabel('support & privacy', isColorGreen: true),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'help & support',
          onTap: controller.openHelpSupport,
        ),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'privacy policy',
          onTap: controller.openPrivacyPolicy,
        ),
        const SettingsRule(horizontal: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: SettingsUnderlineButton(
            label: 'log out',
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
                Text('version 2.1.0',
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
      confirmLabel: 'log out',
    );
    if (confirmed) {
      await controller.signOut();
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}
