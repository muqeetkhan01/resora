import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _session = Get.find<AppSessionController>();

  final step = 0.obs; // 0..6 (cover + 6 post-cover screens)
  final selectedStates = <String>[].obs;
  final selectedReasons = <String>[].obs;
  final intention = ''.obs;
  final name = ''.obs;
  final selectedPlan = 'year'.obs; // year | month | lifetime

  static const totalStepsAfterCover = 6;

  static const states = <({String key, String label})>[
    (key: 'break', label: 'I need a break from everything.'),
    (key: 'out_of_sync', label: 'I’m feeling really out of sync with myself.'),
    (key: 'pause', label: 'Just here to breathe and take a pause.'),
    (
      key: 'next_step',
      label: 'I’m doing okay, just focusing on the next step.',
    ),
    (
      key: 'myself_again',
      label: 'I’m finally starting to feel like myself again.',
    ),
    (key: 'ready', label: 'I feel good and ready for what’s next.'),
    (key: 'other', label: 'Other'),
  ];

  static const reasons = <String>[
    'Honestly, it’s just been a really hard day.',
    'My mind is running a million miles a minute.',
    'I’m feeling a bit overwhelmed by life lately.',
    'I have a lot on my plate and need a second to think.',
    'I’m trying to prevent a burnout before it happens.',
    'I just need a few minutes of total silence.',
    'Showing up for myself today.',
    'Other',
  ];

  static const paywallIncludes = <({String title, String body})>[
    (
      title: 'On-demand guidance',
      body:
          'AI powered guidance, built by a behavioral specialist for your heavy days.',
    ),
    (
      title: 'Guided meditations',
      body: 'Calm audio spaces to help you slow down and find clarity.',
    ),
    (
      title: 'Interactive journaling',
      body: 'Mindful prompts to get things out of your head and onto paper.',
    ),
  ];

  static const paywallPlans =
      <({String key, String label, String price, String meta, String? note})>[
    (
      key: 'lifetime',
      label: 'Lifetime',
      price: '\$249.99',
      meta: 'A one time investment in your well-being.',
      note: 'Yours forever'
    ),
    (
      key: 'year',
      label: 'Yearly',
      price: '\$49.99 / year',
      meta: 'Save 58% compared to monthly.',
      note: 'Most popular'
    ),
    (
      key: 'month',
      label: 'Monthly',
      price: '\$9.99 / month',
      meta: 'Flexible access, cancel whenever you need to.',
      note: null
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    if (_session.isAuthenticated) {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  int get clampedStep => step.value.clamp(0, 6);
  bool get canContinueState => selectedStates.isNotEmpty;
  bool get canContinueIntention => intention.value.trim().length >= 2;

  void next() {
    if (step.value < 6) {
      step.value += 1;
    }
  }

  void back() {
    if (step.value > 0) {
      step.value -= 1;
    }
  }

  void toggleStateValue(String key) {
    final next = List<String>.from(selectedStates);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    selectedStates.assignAll(next);
  }

  void toggleReason(String value) {
    final next = List<String>.from(selectedReasons);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    selectedReasons.assignAll(next);
  }

  void setIntention(String value) {
    intention.value = value;
  }

  void setName(String value) {
    name.value = value;
  }

  void selectPlan(String key) {
    if (key != 'year' && key != 'month' && key != 'lifetime') {
      return;
    }
    selectedPlan.value = key;
  }

  void enterApp() {
    Get.offAllNamed(AppRoutes.welcome);
  }
}
