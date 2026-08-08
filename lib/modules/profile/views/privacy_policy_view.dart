import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import 'widgets/settings_flow_widgets.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  var _showFullPolicy = false;

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      children: [
        const SettingsTopBack(title: ''),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'Privacy Policy',
            style: SettingsFlowText.display(context, size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PolicyParagraph('Your privacy matters to us.'),
              const _PolicyParagraph(
                'Resora collects information needed to create and secure your account, provide your experience, manage membership access, improve reliability, and respond to support requests.',
              ),
              const _PolicyParagraph(
                'When you use features like Talk to Resora, Journal, Guided Resets, Rehearse the Moment, Quiet the Noise, and Key Terms, your activity may be stored so the app can work properly.',
              ),
              const _PolicyParagraph(
                'Talk to Resora uses AI technology to generate responses. Messages you send may be processed by trusted AI service providers to provide this feature.',
              ),
              const _PolicyParagraph(
                'Resora is not a medical, therapy, crisis, or emergency service.',
              ),
              const SizedBox(height: 10),
              SettingsUnderlineButton(
                label: _showFullPolicy
                    ? 'Hide Full Privacy Policy'
                    : 'Read Full Privacy Policy',
                color: SettingsFlowColors.terracotta,
                onTap: () => setState(() => _showFullPolicy = !_showFullPolicy),
              ),
              const SizedBox(height: 18),
              SettingsUnderlineButton(
                label: 'Terms of Use',
                color: SettingsFlowColors.terracotta,
                onTap: () => Get.toNamed(AppRoutes.termsOfUse),
              ),
              if (_showFullPolicy) ...[
                const SizedBox(height: 28),
                const SettingsRule(horizontal: 0),
                const SizedBox(height: 24),
                _section(
                  context,
                  'Effective date',
                  'August 2, 2026',
                ),
                _section(
                  context,
                  'Overview',
                  'Resora respects your privacy. This privacy policy explains what information Resora collects, how it is collected, how it is used and shared, how it is protected, and the choices you have.',
                ),
                _section(
                  context,
                  'Information we collect',
                  'Resora may collect account information such as your name, email address, user ID, sign in provider, and profile details, app content you create such as journal entries, reflections, community questions, Talk to Resora messages, saved preferences, and feature activity, app activity such as chat session state and usage limits, device and app information needed for security, diagnostics, and reliability, feedback and support requests, and subscription status or purchase related identifiers needed to manage access.',
                ),
                _section(
                  context,
                  'How we collect information',
                  'We collect information when you create or sign in to an account, enter content in the app, use Talk to Resora, save preferences, contact support, make or restore a purchase, or when the app and its service providers process technical information needed to operate the service.',
                ),
                _section(
                  context,
                  'How we use information',
                  'We use information to provide and improve Resora, authenticate your account, save and sync your content, generate Talk to Resora responses, personalize your experience, manage membership access, restore purchases, respond to support requests, improve app performance, maintain safety and security, prevent misuse, and comply with legal, Apple App Store, and Google Play requirements.',
                ),
                _section(
                  context,
                  'Talk to Resora and AI processing',
                  'Talk to Resora uses artificial intelligence to generate responses. Messages you send, recent conversation context, and limited memory or profile context may be transmitted to trusted AI technology providers, including OpenAI, to provide and improve this feature. Avoid entering highly sensitive personal, medical, financial, legal, or child identifying information unless necessary for your own use of the app.',
                ),
                _section(
                  context,
                  'Journal and reflection content',
                  'Your journal entries and reflections are personal to your account. Resora uses this information to provide app features and save your content. We do not sell your journal entries, reflections, or Talk to Resora messages.',
                ),
                _section(
                  context,
                  'Community submissions',
                  'Information you submit through community features may be visible to other users, depending on how the feature is designed and the audience you select. Do not include sensitive personal information or unnecessary identifying information in community submissions.',
                ),
                _section(
                  context,
                  'How we share information',
                  'Resora does not sell your personal information. We may share limited information with trusted service providers that help us operate the app. These providers include Google Firebase for authentication, database, storage, and cloud services, Apple and Google for sign in and app store purchases, RevenueCat for subscription management, OpenAI for AI powered Talk to Resora responses, and providers used for diagnostics, customer support, legal, security, or safety compliance. These providers are expected to protect user data in a manner consistent with this policy and applicable platform requirements.',
                ),
                _section(
                  context,
                  'Tracking and advertising',
                  'Resora does not use your journal entries, reflections, or Talk to Resora messages for third party advertising. Resora does not sell personal information or knowingly share personal information with data brokers.',
                ),
                _section(
                  context,
                  'Children and minors',
                  'Resora is not intended for children under 13. If you use Resora to reflect on caregiving situations, avoid entering unnecessary identifying information about a child.',
                ),
                _section(
                  context,
                  'Health, wellness, and safety',
                  'Resora is a wellness and reflection app. It is not medical care, therapy, diagnosis, crisis counseling, emergency support, legal advice, or a substitute for professional services. If you or someone else may be in danger or needs urgent support, contact emergency services or a qualified professional immediately.',
                ),
                _section(
                  context,
                  'Data storage and security',
                  'We use reasonable technical and organizational safeguards to protect your information. No app, database, or internet transmission is completely secure, so we cannot guarantee absolute security.',
                ),
                _section(
                  context,
                  'Data retention',
                  'We keep account information and saved app content while your account is active or as needed to provide Resora. If you request deletion, we will delete or de identify account data unless retention is required for legal, security, fraud prevention, accounting, dispute, backup, or compliance reasons.',
                ),
                _section(
                  context,
                  'Your choices and rights',
                  'You may request access to, correction of, or deletion of your personal information inside the app or by emailing hello@resoraco.com.',
                ),
                _section(
                  context,
                  'Account deletion',
                  'You may request deletion of your account from Profile, then Delete Account, or by emailing hello@resoraco.com. Deleting your account does not automatically cancel an active app store subscription.',
                ),
                _section(
                  context,
                  'Subscriptions and purchases',
                  'Resora may offer paid memberships including monthly, yearly, or lifetime access. Purchases are processed through Apple, Google, RevenueCat, or the applicable app store provider.',
                ),
                _section(
                  context,
                  'Device permissions',
                  'Resora only requests device permissions when needed for app features. Future permissions will always be requested through the system permission prompt.',
                ),
                _section(
                  context,
                  'Changes to this policy',
                  'We may update this privacy policy from time to time. If we make important changes, we may notify you in the app, by email, or by updating the effective date.',
                ),
                _section(
                  context,
                  'Contact us',
                  'Questions about this privacy policy or your data can be sent to hello@resoraco.com.',
                ),
              ],
              const SizedBox(height: 24),
              const SettingsRule(horizontal: 0),
              const SizedBox(height: 24),
              const _PolicyParagraph(
                'Questions about your data? Email us at hello@resoraco.com.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
          Text(
            body,
            style: SettingsFlowText.body(context, size: 12),
          ),
        ],
      ),
    );
  }
}

class _PolicyParagraph extends StatelessWidget {
  const _PolicyParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: SettingsFlowText.body(context, size: 13),
      ),
    );
  }
}
