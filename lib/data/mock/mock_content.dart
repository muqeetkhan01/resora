import '../../core/constants/app_icons.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../models/app_models.dart';

abstract final class MockContent {
  static const userName = 'Amber';

  static const onboarding = [
    OnboardingItem(
      title: 'A softer way to hold the day',
      subtitle: 'Emotional support that meets you in the middle of real life.',
      caption:
          'Grounding tools, soothing rituals, and calm design made for busy hearts.',
      icon: AppIcons.emotionalSupport,
      accentColor: AppColors.peach,
    ),
    OnboardingItem(
      title: 'Parent with more calm',
      subtitle: 'Reset your nervous system before the next hard moment.',
      caption:
          'Short reflections, regulation prompts, and parenting support that feels gentle.',
      icon: AppIcons.parentingCalm,
      accentColor: AppColors.blush,
    ),
    OnboardingItem(
      title: 'Guidance that feels personal',
      subtitle:
          'An AI companion to help you process, reflect, and feel supported.',
      caption:
          'Ask for clarity, routines, co-regulation tips, or a thoughtful reframe.',
      icon: AppIcons.aiGuidance,
      accentColor: AppColors.gold,
    ),
    OnboardingItem(
      title: 'Wellness tools for every season',
      subtitle:
          'Meditations, ASMR, visualizations, journaling, and affirmations.',
      caption:
          'Build a private care space you can return to any time you need steadiness.',
      icon: AppIcons.wellnessTools,
      accentColor: AppColors.sage,
    ),
  ];

  static const quickActions = [
    QuickActionItem(
      title: 'AI Chat',
      subtitle: 'Talk it through',
      icon: AppIcons.aiChat,
      accentColor: AppColors.blush,
      route: AppRoutes.chat,
    ),
    QuickActionItem(
      title: 'Journal',
      subtitle: 'Write gently',
      icon: AppIcons.journal,
      accentColor: AppColors.peach,
      route: AppRoutes.dashboard,
      dashboardIndex: 1,
    ),
    QuickActionItem(
      title: 'Affirmations',
      subtitle: 'Daily words',
      icon: AppIcons.affirmations,
      accentColor: AppColors.gold,
      route: AppRoutes.affirmations,
    ),
    QuickActionItem(
      title: 'Meditation',
      subtitle: 'Find stillness',
      icon: AppIcons.meditation,
      accentColor: AppColors.sage,
      route: AppRoutes.mindfulness,
      routeArguments: 0,
    ),
    QuickActionItem(
      title: 'ASMR',
      subtitle: 'Soothing sound',
      icon: AppIcons.asmr,
      accentColor: AppColors.peach,
      route: AppRoutes.mindfulness,
      routeArguments: 1,
      premium: true,
    ),
    QuickActionItem(
      title: 'Visualize',
      subtitle: 'Soft imagery',
      icon: AppIcons.visualizations,
      accentColor: AppColors.blush,
      route: AppRoutes.mindfulness,
      routeArguments: 2,
      premium: true,
    ),
    QuickActionItem(
      title: 'Q&A',
      subtitle: 'Expert library',
      icon: AppIcons.questions,
      accentColor: AppColors.sage,
      route: AppRoutes.qa,
    ),
    QuickActionItem(
      title: 'Community',
      subtitle: 'Warm support',
      icon: AppIcons.community,
      accentColor: AppColors.gold,
      route: AppRoutes.dashboard,
      dashboardIndex: 2,
    ),
  ];

  static const suggestedPrompts = [
    'How do I reset after a hard parenting moment?',
    'Give me a 2-minute calming ritual.',
    'Help me reframe today with more compassion.',
  ];

  static const chatMessages = [
    ChatMessageModel(
      text:
          'I felt overstimulated after school pickup and snapped too quickly.',
      isUser: true,
      time: '6:12 PM',
    ),
    ChatMessageModel(
      text:
          'You are noticing it with care, and that matters. Want a tiny repair script plus a 60-second reset for your body?',
      isUser: false,
      time: '6:13 PM',
    ),
    ChatMessageModel(
      text: 'Yes, something short that I can actually do tonight.',
      isUser: true,
      time: '6:13 PM',
    ),
    ChatMessageModel(
      text:
          'Try this: hand to heart, one slow exhale, then say “I was overwhelmed, and I want to begin again with you.”',
      isUser: false,
      time: '6:14 PM',
    ),
  ];

  static const journalPrompts = [
    'What felt tender today, and what did I need most in that moment?',
    'Where did calm show up, even briefly?',
    'What can I release before tonight?',
  ];

  static const journalEntries = [
    JournalEntry(
      title: 'A softer bedtime reset',
      preview: 'Tonight felt less rushed when I lowered my own voice first...',
      date: 'Today',
      moods: ['Calm', 'Present'],
    ),
    JournalEntry(
      title: 'After the morning rush',
      preview:
          'I noticed how much tension I carry before 8 AM and how it shapes the room...',
      date: 'Yesterday',
      moods: ['Overwhelmed', 'Hopeful'],
    ),
    JournalEntry(
      title: 'What repair looked like',
      preview:
          'I came back after the hard moment. Not perfectly, but honestly...',
      date: 'Tuesday',
      moods: ['Reflective', 'Connected'],
    ),
  ];

  static const affirmations = [
    AffirmationItem(
      category: 'For Mothers',
      text: 'I can lead with gentleness and still hold strong boundaries.',
      duration: '3 min listen',
      isSaved: true,
    ),
    AffirmationItem(
      category: 'Nervous System',
      text: 'Safety can be built in small moments, one breath at a time.',
      duration: '2 min listen',
    ),
    AffirmationItem(
      category: 'Healing',
      text: 'I do not need to rush my restoration to deserve rest.',
      duration: '4 min listen',
      isPremium: true,
    ),
  ];

  static const mindfulnessTabs = ['Meditation', 'ASMR', 'Visualizations'];

  static const mindfulnessSessions = [
    MindfulnessSession(
      title: 'Morning exhale',
      subtitle: 'A light guided reset before the day begins',
      length: '8 min',
      type: 'Meditation',
      color: AppColors.sage,
    ),
    MindfulnessSession(
      title: 'Soft rain for regulation',
      subtitle: 'Low-stimulation sound to settle the nervous system',
      length: '22 min',
      type: 'ASMR',
      color: AppColors.peach,
      isPremium: true,
    ),
    MindfulnessSession(
      title: 'Safe home visualization',
      subtitle: 'Imagine warmth, steadiness, and spacious breath',
      length: '12 min',
      type: 'Visualizations',
      color: AppColors.blush,
      isPremium: true,
    ),
    MindfulnessSession(
      title: 'Between tasks pause',
      subtitle: 'A tiny pause to reconnect with yourself',
      length: '5 min',
      type: 'Meditation',
      color: AppColors.gold,
    ),
  ];

  static const qas = [
    QaItem(
      question: 'How can I stay calm when my child escalates?',
      answer:
          'Begin with your own body first: soften your jaw, lengthen your exhale, then lower the pace of your voice. Calm is contagious when it is embodied.',
      category: 'Parenting Calm',
    ),
    QaItem(
      question: 'What if I keep feeling guilty after hard moments?',
      answer:
          'Guilt can become useful when it leads to repair, reflection, and more support for you. It does not need to become your identity.',
      category: 'Emotional Healing',
    ),
    QaItem(
      question: 'Can I ask an expert for a more personalized answer?',
      answer:
          'Premium members will be able to unlock deeper expert-guided answers and curated care plans.',
      category: 'Expert Answers',
      isPremium: true,
    ),
  ];

  static const communityPosts = [
    CommunityPost(
      author: 'Layla R.',
      role: 'Mother of two',
      title: 'A bedtime phrase that changed our evenings',
      preview:
          'I started saying “we can do bedtime softly” and the whole room shifted. It felt small, but it helped me stay regulated too.',
      category: 'Daily Wins',
      likes: 124,
      comments: 19,
    ),
    CommunityPost(
      author: 'Nadia K.',
      role: 'Healing after burnout',
      title: 'How I use 5-minute pauses now',
      preview:
          'Instead of waiting for a perfect hour, I’ve been stacking tiny rituals through the day. It feels more realistic and kind.',
      category: 'Mindfulness',
      likes: 86,
      comments: 12,
    ),
  ];

  static const profileOptions = [
    ProfileOption(
        label: 'Saved Content',
        icon: AppIcons.bookmark,
        trailing: '18'),
    ProfileOption(
        label: 'Notifications',
        icon: AppIcons.notification,
        trailing: 'Daily'),
    ProfileOption(label: 'Privacy', icon: AppIcons.privacy),
    ProfileOption(label: 'Help & Support', icon: AppIcons.help),
    ProfileOption(label: 'Logout', icon: AppIcons.logout),
  ];

  static const premiumPlans = [
    PremiumPlan(
      title: 'Monthly',
      price: '\$12',
      caption: 'Flexible support, billed monthly',
      highlight: false,
    ),
    PremiumPlan(
      title: 'Yearly',
      price: '\$89',
      caption: 'Best value, includes premium rituals and expert answers',
      highlight: true,
    ),
  ];

  static const categories = [
    'All',
    'Parenting Calm',
    'Emotional Healing',
    'Sleep',
    'Mindfulness',
  ];
}
