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
    'Early access to new features',
    'Cancel anytime',
  ];

  static const _plans = [
    _Plan(
      'monthly',
      'Monthly',
      '\$9.99 / month',
      'Flexible access, cancel anytime.',
      null,
    ),
    _Plan(
      'yearly',
      'Yearly',
      '\$49.99 / year',
      'Our best value. Save 30%.',
      null,
    ),
    _Plan(
      'lifetime',
      'Lifetime',
      '\$249.99',
      'One payment, yours forever.',
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
              child: Text('membership',
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
                'included with premium:',
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
                          ? 'restoring...'
                          : 'restore purchase',
                      color: SettingsFlowColors.terracotta,
                      onTap: controller.restorePurchases,
                    )
                  else
                    const SizedBox.shrink(),
                  SettingsUnderlineButton(
                    label: 'explore membership',
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
              controller.isPremium.value ? 'premium' : 'free',
              style: SettingsFlowText.body(context, size: 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Text('membership',
              style: SettingsFlowText.display(context, size: 32)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Text('CHOOSE THE EXPERIENCE THAT SUPPORTS YOU',
              style: SettingsFlowText.caps(context, size: 9)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() => Column(
                  children: _plans.map((plan) {
                    final selected = plan.id == _selectedPlan;
                    final livePrice = controller.priceForPlan(plan.id);
                    final price = livePrice == null
                        ? plan.price
                        : plan.note == null
                            ? livePrice
                            : '$livePrice ${plan.id == 'monthly' ? '/ month' : plan.id == 'yearly' ? '/ year' : ''}'
                                .trim();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPlan = plan.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? SettingsFlowColors.forestGreen.withOpacity(0.05)
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
                                  Text(plan.label,
                                      style: SettingsFlowText.title(context,
                                          size: 14)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$price\n${plan.note}',
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
                        ? 'restoring...'
                        : 'restore purchase',
                    color: SettingsFlowColors.terracotta,
                    onTap: controller.restorePurchases,
                  )
                else
                  const SizedBox.shrink(),
                SettingsUnderlineButton(
                  label:
                      controller.isSubscriptionBusy ? 'working...' : 'continue',
                  color: SettingsFlowColors.warmDark,
                  onTap: () async {
                    if (controller.isSubscriptionBusy) {
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
              'welcome to\nresora premium',
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
              label: 'continue',
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
