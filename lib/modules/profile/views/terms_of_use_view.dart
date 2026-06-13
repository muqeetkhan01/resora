import 'package:flutter/material.dart';

import 'widgets/settings_flow_widgets.dart';

class TermsOfUseView extends StatelessWidget {
  const TermsOfUseView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      children: [
        const SettingsTopBack(title: ''),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'terms of use',
            style: SettingsFlowText.display(context, size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TermsParagraph(
                  'By using Resora, you agree to these Terms of Use.'),
              _TermsSection(
                'what resora provides',
                'Resora offers wellness tools for reflection, journaling, guided resets, visualization, calming audio, key terms, and supportive conversation through Talk to Resora.',
              ),
              _TermsSection(
                'safety disclaimer',
                'Resora is not medical care, therapy, mental health treatment, diagnosis, crisis counseling, emergency support, legal advice, or a substitute for professional services.',
              ),
              _TermsSection(
                'ai responses',
                'Talk to Resora may use artificial intelligence to generate responses. AI responses may not always be complete, accurate, or suitable for your specific situation.',
              ),
              _TermsSection(
                'user responsibility',
                'Use Resora responsibly. Do not use the app for emergencies, unlawful activity, harmful content, or decisions that require professional medical, legal, financial, or safety guidance.',
              ),
              _TermsSection(
                'subscriptions',
                'Purchases, cancellations, refunds, and billing are handled through Apple or the applicable app store provider. Subscriptions renew automatically unless canceled in your Apple account settings.',
              ),
              _TermsSection(
                'contact',
                'Questions about these Terms can be sent to hello@resoraco.com.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection(this.title, this.body);

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

class _TermsParagraph extends StatelessWidget {
  const _TermsParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(text, style: SettingsFlowText.body(context, size: 13)),
    );
  }
}
