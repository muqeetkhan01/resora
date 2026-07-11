import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/settings_flow_widgets.dart';

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      children: [
        const SettingsTopBack(title: ''),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'Delete Account',
            style: SettingsFlowText.display(context, size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DeleteParagraph(
                'You can request deletion of your Resora account and saved data.',
              ),
              const _DeleteSection(
                'Before Deleting',
                'Deleting your account may remove saved content, journal entries, Talk to Resora history, preferences, and membership-related app data.',
              ),
              const _DeleteSection(
                'Important Note',
                'Some information may be retained if required for legal, security, fraud prevention, accounting, or compliance reasons.',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingsUnderlineButton(
                    label: 'Cancel',
                    color: SettingsFlowColors.muted,
                    onTap: Get.back,
                  ),
                  SettingsUnderlineButton(
                    label: 'Request Account Deletion',
                    color: SettingsFlowColors.destructiveRed,
                    onTap: () => _showRequestInfo(context),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const SettingsRule(horizontal: 0),
              const SizedBox(height: 24),
              const _DeleteParagraph(
                'Need help? Email hello@resoraco.com.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showRequestInfo(BuildContext context) async {
    await showSettingsConfirm(
      context,
      title: 'Request Account Deletion',
      message:
          'Email hello@resoraco.com from the email connected to your Resora account. The Resora team will help delete your account and saved data.',
      confirmLabel: 'Got It',
      destructive: true,
    );
  }
}

class _DeleteSection extends StatelessWidget {
  const _DeleteSection(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SettingsFlowText.caps(
              context,
              size: 10,
              color: SettingsFlowColors.terracotta,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: SettingsFlowText.body(context, size: 13)),
        ],
      ),
    );
  }
}

class _DeleteParagraph extends StatelessWidget {
  const _DeleteParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(text, style: SettingsFlowText.body(context, size: 13)),
    );
  }
}
