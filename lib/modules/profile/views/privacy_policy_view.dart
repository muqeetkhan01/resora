import 'package:flutter/material.dart';

import 'widgets/settings_flow_widgets.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      children: [
        const SettingsTopBack(title: ''),
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
              Text(
                'Privacy policy content is being finalized by the Resora team.',
                style: SettingsFlowText.body(context, size: 13),
              ),
              const SizedBox(height: 24),
              Container(
                height: 0.5,
                color: SettingsFlowColors.border,
              ),
              const SizedBox(height: 24),
              Text(
                'Questions about how we handle your data?\nReach us at privacy@resora.com.',
                style: SettingsFlowText.body(context, size: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
