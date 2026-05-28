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
                IconButton(
                  onPressed: Get.back,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 28, height: 28),
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: Color(0xFFA3A3A3),
                  ),
                ),
                Text('settings',
                    style: SettingsFlowText.display(context, size: 36)),
                const SizedBox(height: 6),
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
        const SectionLabel('your journey'),
        const SettingsRule(horizontal: 0),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              _JourneyStat(value: '12', label: 'days checked in'),
              _JourneyStat(
                value: '7',
                label: 'quiet resets',
                alignment: CrossAxisAlignment.center,
              ),
              _JourneyStat(
                value: '28',
                label: 'journal entries',
                alignment: CrossAxisAlignment.end,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
          child: Text(
            'Keep showing up.\nYour future self is taking notes.',
            style: SettingsFlowText.body(context, size: 12),
          ),
        ),
        const SectionLabel('your space'),
        const SettingsRule(horizontal: 0),
        Obx(
          () => SettingsRow(
            label: 'journal lock',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SettingsToggle(
                  value: controller.journalLockEnabled.value,
                  onChanged: (value) {
                    if (value) {
                      controller.openJournalLock();
                    } else {
                      controller.toggleJournalLock(false);
                    }
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  '›',
                  style: SettingsFlowText.title(context, size: 18)
                      .copyWith(color: SettingsFlowColors.terracotta),
                ),
              ],
            ),
            onTap: controller.openJournalLock,
          ),
        ),
        const SettingsRule(horizontal: 0),
        Obx(
          () => SettingsRow(
            label: 'affirmations',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SettingsToggle(
                  value: controller.affirmationsEnabled.value,
                  onChanged: controller.toggleAffirmations,
                ),
                const SizedBox(width: 10),
                Text(
                  '›',
                  style: SettingsFlowText.title(context, size: 18)
                      .copyWith(color: SettingsFlowColors.terracotta),
                ),
              ],
            ),
            onTap: () => controller.toggleAffirmations(
              !controller.affirmationsEnabled.value,
            ),
          ),
        ),
        const SettingsRule(horizontal: 0),
        const SectionLabel('membership'),
        const SettingsRule(horizontal: 0),
        SettingsRow(
          label: 'membership',
          subtitle: 'Elevate your experience.',
          onTap: controller.openSubscription,
        ),
        const SettingsRule(horizontal: 0),
        const SectionLabel('support & privacy'),
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
                Text(
                  'r e s o r a',
                  style: SettingsFlowText.display(context, size: 18).copyWith(
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
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

class _JourneyStat extends StatelessWidget {
  const _JourneyStat({
    required this.value,
    required this.label,
    this.alignment = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text(value, style: SettingsFlowText.display(context, size: 30)),
          const SizedBox(height: 2),
          Text(label, style: SettingsFlowText.caps(context, size: 10)),
        ],
      ),
    );
  }
}
