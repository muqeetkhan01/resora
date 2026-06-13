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
            'privacy policy',
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
                'Resora collects information needed to provide your experience, manage your membership, improve the app, and respond to support requests.',
              ),
              const _PolicyParagraph(
                'When you use features like Talk to Resora, Journal, Guided Resets, Rehearse the Moment, Quiet the Noise, and Key Terms, your activity may be stored so the app can work properly.',
              ),
              const _PolicyParagraph(
                'Talk to Resora may use AI technology to generate responses. Messages you send may be processed by trusted service providers to provide this feature.',
              ),
              const _PolicyParagraph(
                'Resora is not a medical, therapy, crisis, or emergency service.',
              ),
              const SizedBox(height: 10),
              SettingsUnderlineButton(
                label: _showFullPolicy
                    ? 'hide full privacy policy'
                    : 'read full privacy policy',
                color: SettingsFlowColors.terracotta,
                onTap: () => setState(() => _showFullPolicy = !_showFullPolicy),
              ),
              const SizedBox(height: 18),
              SettingsUnderlineButton(
                label: 'terms of use',
                color: SettingsFlowColors.terracotta,
                onTap: () => Get.toNamed(AppRoutes.termsOfUse),
              ),
              if (_showFullPolicy) ...[
                const SizedBox(height: 28),
                const SettingsRule(horizontal: 0),
                const SizedBox(height: 24),
                _section(
                  context,
                  'effective date',
                  '[Insert Date]',
                ),
                _section(
                  context,
                  'overview',
                  'Resora respects your privacy. This Privacy Policy explains what information we collect, how we use it, how we protect it, and the choices you have. By using Resora, you agree to this Privacy Policy.',
                ),
                _section(
                  context,
                  'information we collect',
                  'Resora may collect account information, app content you create, app activity, device/app information, feedback, support requests, and subscription status. App content may include journal entries, reflections, Talk to Resora messages, saved preferences, and feature activity.',
                ),
                _section(
                  context,
                  'how we use information',
                  'We use information to provide and improve Resora, save your content, provide Talk to Resora responses, manage membership access, respond to support requests, improve app performance, maintain safety and security, and comply with legal or App Store requirements.',
                ),
                _section(
                  context,
                  'talk to resora and ai processing',
                  'Talk to Resora may use artificial intelligence to generate responses. Messages you send may be processed by trusted technology providers to provide this feature. Avoid entering highly sensitive personal, medical, financial, legal, or child-identifying information unless necessary for your own use of the app.',
                ),
                _section(
                  context,
                  'journal and reflection content',
                  'Your journal entries and reflections are personal to your account. Resora uses this information to provide app features and save your content. We do not sell your journal entries, reflections, or Talk to Resora messages.',
                ),
                _section(
                  context,
                  'how we share information',
                  'Resora does not sell your personal information. We may share limited information with trusted service providers that help us operate the app, including cloud storage, AI processing, analytics, crash reporting, subscription management, customer support, and legal or safety compliance.',
                ),
                _section(
                  context,
                  'children and minors',
                  'Resora is not intended for children under 13. If you use Resora to reflect on caregiving situations, avoid entering unnecessary identifying information about a child, such as full name, address, school name, medical record numbers, or other highly identifying details.',
                ),
                _section(
                  context,
                  'health, wellness, and safety',
                  'Resora is a wellness and reflection app. It is not medical care, therapy, diagnosis, crisis counseling, emergency support, legal advice, or a substitute for professional services. If you or someone else may be in danger or needs urgent support, call emergency services or contact a qualified professional immediately.',
                ),
                _section(
                  context,
                  'data storage and security',
                  'We use reasonable technical and organizational safeguards to protect your information. No app, database, or internet transmission is completely secure, so we cannot guarantee absolute security.',
                ),
                _section(
                  context,
                  'data retention',
                  'We keep information for as long as needed to provide Resora, maintain your account, comply with legal obligations, resolve disputes, improve app safety, and operate the app. Some information may be retained if required for legal, security, fraud prevention, accounting, or compliance reasons.',
                ),
                _section(
                  context,
                  'your choices and rights',
                  'You may request access to, correction of, or deletion of your personal information by emailing hello@resoraco.com or using the account deletion option inside the app when available.',
                ),
                _section(
                  context,
                  'account deletion',
                  'If you create an account, you may request deletion of your account and saved data inside the app or by emailing hello@resoraco.com. Deleting your account may remove saved content, journal entries, Talk to Resora history, preferences, and membership-related app data, except information we are required or permitted to keep.',
                ),
                _section(
                  context,
                  'subscriptions and purchases',
                  'Resora may offer paid memberships, including monthly, yearly, or lifetime access. Purchases are processed through Apple or the applicable app store provider. Subscription billing, cancellation, refunds, and payment settings are managed through your app store account.',
                ),
                _section(
                  context,
                  'push notifications',
                  'If Resora offers notifications, you may choose whether to allow them. You can turn notifications on or off in your device settings at any time.',
                ),
                _section(
                  context,
                  'changes to this policy',
                  'We may update this Privacy Policy from time to time. If we make important changes, we may notify you in the app, by email, or by updating the effective date.',
                ),
                _section(
                  context,
                  'contact us',
                  'Questions about this Privacy Policy or your data can be sent to hello@resoraco.com.',
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
