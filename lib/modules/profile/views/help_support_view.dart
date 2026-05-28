import 'package:flutter/material.dart';

import 'widgets/settings_flow_widgets.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  String? _expanded;

  static const _items = [
    _SupportItem(
      'faq',
      'frequently asked questions',
      'Answers to common questions.',
      'Content for frequently asked questions is being finalized by the Resora team. Check back soon.',
    ),
    _SupportItem(
      'contact',
      'contact us',
      'Reach the Resora team directly.',
      'To reach the Resora team directly, email us at hello@resora.com. We respond within one business day.',
    ),
    _SupportItem(
      'feedback',
      'send feedback',
      'Tell us what you think.',
      'Your feedback shapes Resora. Send notes, requests, or thoughts directly to the team.',
    ),
    _SupportItem(
      'issue',
      'report an issue',
      'Something not working properly?',
      'Please describe the issue and what you were doing when it happened so the team can look into it.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      scrollable: false,
      children: [
        const SettingsTopBack(title: ''),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'help & support',
            style: SettingsFlowText.display(context, size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'We are here if you need us.\nEverything below goes directly to the Resora team.',
            style: SettingsFlowText.body(context, size: 13),
          ),
        ),
        const SettingsRule(horizontal: 0),
        Expanded(
          child: ListView(
            children: [
              ..._items.map((item) {
                final expanded = _expanded == item.id;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                        () => _expanded = expanded ? null : item.id,
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: SettingsFlowColors.border,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: SettingsFlowText.title(
                                          context,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: SettingsFlowText.body(
                                          context,
                                          size: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedRotation(
                                  turns: expanded ? 0.25 : 0,
                                  duration: const Duration(milliseconds: 180),
                                  child: Text(
                                    '›',
                                    style: SettingsFlowText.title(
                                      context,
                                      size: 18,
                                    ).copyWith(
                                      color: SettingsFlowColors.terracotta,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 180),
                              crossFadeState: expanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 4),
                                child: Text(
                                  item.content,
                                  style: SettingsFlowText.body(
                                    context,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SettingsRule(horizontal: 0),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Text(
                  'version 2.1.0 · the resora team',
                  style: SettingsFlowText.caps(context, size: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportItem {
  const _SupportItem(this.id, this.label, this.subtitle, this.content);

  final String id;
  final String label;
  final String subtitle;
  final String content;
}
