import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar.dart';
import 'widgets/settings_flow_widgets.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  final _profileService = UserProfileService();
  var _isSubmitting = false;

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
                'You can request deletion of your Resora account and saved data from inside the app.',
              ),
              const _DeleteSection(
                'Before Deleting',
                'Deletion covers your account profile, saved content, journal entries, Talk to Resora history, preferences, and app data associated with your account.',
              ),
              const _DeleteSection(
                'Subscriptions',
                'Deleting your Resora account does not automatically cancel an active app store subscription. Manage billing or cancellation in your Apple or Google account settings.',
              ),
              const _DeleteSection(
                'What May Be Kept',
                'Some records may be retained only when required for legal, security, fraud prevention, accounting, dispute, or compliance reasons.',
              ),
              const _DeleteSection(
                'Timing',
                'Most deletion requests are reviewed and completed within 30 days. We will confirm completion using the email connected to your account.',
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
                    label: _isSubmitting
                        ? 'Submitting...'
                        : 'Request Account Deletion',
                    color: SettingsFlowColors.destructiveRed,
                    onTap:
                        _isSubmitting ? () {} : () => _submitRequest(context),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const SettingsRule(horizontal: 0),
              const SizedBox(height: 24),
              const _DeleteParagraph(
                'You can also request deletion from the web at https://resoraco.com/account-deletion or email hello@resoraco.com for help.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    final confirmed = await showSettingsConfirm(
      context,
      title: 'Request Account Deletion',
      message:
          'This will submit a deletion request for your Resora account and saved data. You will be signed out after the request is recorded.',
      confirmLabel: 'Submit Request',
      destructive: true,
    );
    if (!confirmed || _isSubmitting) {
      return;
    }

    final session = Get.find<AppSessionController>();
    final user = session.firebaseUser;
    if (user == null) {
      showAppSnackbar(
        'Sign in required',
        'Please sign in before requesting account deletion.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _profileService.requestAccountDeletion(user: user);
      await session.signOut();
      Get.offAllNamed(AppRoutes.welcome);
      showAppSnackbar(
        'Deletion requested',
        'Your request was recorded. We will confirm completion by email.',
      );
    } catch (_) {
      showAppSnackbar(
        'Request failed',
        'We could not submit the request. Please try again or email hello@resoraco.com.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
