import 'package:get/get.dart';

import '../../../core/controllers/app_session_controller.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _session = Get.find<AppSessionController>();

  final step = 0.obs; // 0..6 (cover + 6 post-cover screens)
  final selectedState = RxnString();
  final selectedReasons = <String>[].obs;
  final intention = ''.obs;
  final name = ''.obs;
  final selectedPlan = 'year'.obs; // year | month | lifetime

  static const totalStepsAfterCover = 6;

  static const states = <({String key, String label})>[
    (key: 'heavy', label: 'Heavy, a little underwater'),
    (key: 'wired', label: 'Wired, need to come down'),
    (key: 'stuck', label: 'Stuck, spinning in my head'),
    (key: 'tender', label: 'Tender, something is up'),
    (key: 'distant', label: 'Distant from someone I love'),
    (key: 'ok', label: 'Fine, just checking in'),
  ];

  static const reasons = <String>[
    'A hard conversation',
    'Too much in my head',
    'A hard day coming up',
    'Feeling disconnected',
    'Wanting a gentler morning',
    'Building a daily practice',
    'Rehearsing something I need to say',
  ];

  static const paywallIncludes = <({String title, String body})>[
    (
      title: '24/7 expert support',
      body:
          'Instant AI guidance designed by our licensed behavioral specialists.',
    ),
    (
      title: 'Guided meditations',
      body: 'Effortless sessions for mental clarity.',
    ),
    (
      title: 'Journal prompts',
      body: 'Writing tools to help you process and grow.',
    ),
  ];

  static const paywallPlans =
      <({String key, String label, String price, String meta, String? note})>[
    (
      key: 'year',
      label: 'Yearly',
      price: '\$49.99',
      meta:
          'Free for 7 days, then less than \$4/mo. We will remind you 48 hours before.',
      note: 'Best value'
    ),
    (
      key: 'month',
      label: 'Monthly',
      price: '\$9.99',
      meta: 'Billed monthly',
      note: null
    ),
    (
      key: 'lifetime',
      label: 'Lifetime',
      price: '\$249.99',
      meta: 'One payment. Full access. No renewals.',
      note: 'Yours forever'
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
  bool get canContinueState => (selectedState.value ?? '').isNotEmpty;
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

  void setStateValue(String key) {
    selectedState.value = key;
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
