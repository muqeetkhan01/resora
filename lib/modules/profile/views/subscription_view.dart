import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import 'widgets/settings_flow_widgets.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  final controller = Get.find<ProfileController>();
  var _stage = _MembershipStage.overview;
  var _selectedPlan = 'monthly';

  static const _features = [
    'Unlimited Talk to Resora conversations',
    'Full access to Gentle Reset audios',
    'Full access to Rehearse the Moment audios',
    'Full access to Quiet the Noise audios',
    'Full access to Journal Prompts',
    'Early access to new features',
    'Cancel anytime',
  ];

  static const _plans = [
    _Plan(
      'lifetime',
      'Lifetime',
      '\$249.99',
      'A one time investment in your well-being.',
      null,
    ),
    _Plan(
      'yearly',
      'Yearly',
      '\$49.99 / year',
      'Save 58% compared to monthly.',
      null,
    ),
    _Plan(
      'monthly',
      'Monthly',
      '\$9.99 / month',
      'Flexible access, cancel whenever you need to.',
      null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsFlowColors.offWhite,
      body: SafeArea(
        child: switch (_stage) {
          _MembershipStage.overview => _overview(context),
          _MembershipStage.plans => _plansView(context),
          _MembershipStage.success => _success(context),
        },
      ),
    );
  }

  Widget _overview(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsTopBack(title: ''),
            const SizedBox(height: 58),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text('Membership',
                  style: SettingsFlowText.display(context, size: 32)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Text(
                'Get more from your time in Resora.\nMore space. More support. More ways to return to yourself.',
                style: SettingsFlowText.title(context, size: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: Text(
                'Included with Premium:',
                style: SettingsFlowText.caps(
                  context,
                  size: 10,
                  color: SettingsFlowColors.terracotta,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: _features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: SettingsFlowColors.border,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 3,
                          color: SettingsFlowColors.terracotta,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: SettingsFlowText.title(context, size: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: Get.height * .1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (controller.canShowRestore)
                    SettingsUnderlineButton(
                      label: controller.isSubscriptionBusy
                          ? 'Restoring...'
                          : 'Restore Purchase',
                      color: SettingsFlowColors.terracotta,
                      onTap: controller.restorePurchases,
                    )
                  else
                    const SizedBox.shrink(),
                  SettingsUnderlineButton(
                    label: 'Explore Membership',
                    color: SettingsFlowColors.terracotta,
                    onTap: () =>
                        setState(() => _stage = _MembershipStage.plans),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _plansView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTopBack(
          title: '',
          trailing: Obx(
            () => Text(
              controller.isPremium.value ? 'Premium' : 'Free',
              style: SettingsFlowText.body(context, size: 12),
            ),
          ),
        ),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text('Membership',
              style: SettingsFlowText.display(context, size: 32)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Text('CHOOSE THE EXPERIENCE THAT SUPPORTS YOU',
              style: SettingsFlowText.caps(context, size: 9)),
        ),
        const SizedBox(height: 38),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => Column(
                  children: _plans.map((plan) {
                    final livePrice = controller.priceForPlan(plan.id);
                    final available = controller.isPlanAvailable(plan.id);
                    final selected = available && plan.id == _selectedPlan;
                    final price = livePrice ?? 'Unavailable';
                    return GestureDetector(
                      onTap: available
                          ? () => setState(() => _selectedPlan = plan.id)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? SettingsFlowColors.forestGreen
                                  .withValues(alpha: 0.05)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? SettingsFlowColors.forestGreen
                                : SettingsFlowColors.border,
                            width: selected ? 0.75 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.label,
                                    style: SettingsFlowText.title(
                                      context,
                                      size: 14,
                                    ).copyWith(
                                      color: available
                                          ? null
                                          : SettingsFlowColors.muted,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    available
                                        ? '$price\n${plan.note}'
                                        : '$price\nNot returned by the App Store.',
                                    style: SettingsFlowText.body(context,
                                        size: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (plan.badge != null)
                              Text(
                                plan.badge!,
                                style: SettingsFlowText.caps(
                                  context,
                                  size: 10,
                                  color: SettingsFlowColors.terracotta,
                                ),
                              ),
                            if (selected) ...[
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.check,
                                color: SettingsFlowColors.forestGreen,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
          child: Text(
            'Subscriptions renew automatically unless canceled in your Apple account settings.',
            style: SettingsFlowText.body(context, size: 10),
          ),
        ),
        Obx(
          () => Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (controller.canShowRestore)
                  SettingsUnderlineButton(
                    label: controller.isSubscriptionBusy
                        ? 'Restoring...'
                        : 'Restore Purchase',
                    color: SettingsFlowColors.terracotta,
                    onTap: controller.restorePurchases,
                  )
                else
                  const SizedBox.shrink(),
                SettingsUnderlineButton(
                  label: controller.isSubscriptionBusy
                      ? 'Checking...'
                      : controller.isPlanAvailable(_selectedPlan)
                          ? 'Continue'
                          : 'Retry Plans',
                  color: SettingsFlowColors.warmDark,
                  onTap: () async {
                    if (controller.isSubscriptionBusy) {
                      return;
                    }

                    if (!controller.isPlanAvailable(_selectedPlan)) {
                      await controller.refreshSubscriptions();
                      return;
                    }

                    final purchased =
                        await controller.purchasePlan(_selectedPlan);
                    if (!mounted || !purchased) {
                      return;
                    }
                    setState(() => _stage = _MembershipStage.success);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _success(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to\nResora Premium',
              textAlign: TextAlign.center,
              style: SettingsFlowText.display(context, size: 34),
            ),
            const SizedBox(height: 20),
            // Container(
            //   width: 32,
            //   height: 0.5,
            //   color: SettingsFlowColors.terracotta,
            // ),
            const SizedBox(height: 28),
            Text(
              "You now have full access to Resora.\nWe're glad you're here.",
              textAlign: TextAlign.center,
              style: SettingsFlowText.body(context, size: 13),
            ),
            const SizedBox(height: 40),
            SettingsUnderlineButton(
              label: 'Continue',
              color: SettingsFlowColors.warmDark,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MembershipStage { overview, plans, success }

class _Plan {
  const _Plan(this.id, this.label, this.price, this.note, this.badge);

  final String id;
  final String label;
  final String price;
  final String? note;
  final String? badge;
}
