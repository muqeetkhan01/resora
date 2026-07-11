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
      'contact',
      'Contact Us',
      'Reach the Resora team directly.',
      'Email us at hello@resoraco.com.\nWe\'ll get back to you within one business day.',
    ),
    _SupportItem(
      'feedback',
      'Send Feedback',
      'Share notes, requests, or ideas with us.',
      'Your feedback helps shape Resora.\nSend us your thoughts, requests, or ideas.\nhello@resoraco.com',
    ),
    _SupportItem(
      'issue',
      'Report an Issue',
      'Tell us if something isn\'t working.',
      'Tell us what happened and what you were doing when the issue came up.\nThis helps our team look into it.\nhello@resoraco.com',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsPageFrame(
      scrollable: false,
      children: [
        const SettingsTopBack(title: ''),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Text(
            'Help & Support',
            style: SettingsFlowText.display(context, size: 32),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'We\'re here if you need us.\nChoose the option that fits best below.',
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
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              //   child: Text(
              //     'version 2.1.0 · the resora team',
              //     style: SettingsFlowText.caps(context, size: 10),
              //   ),
              // ),
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
