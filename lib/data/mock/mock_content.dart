import '../../core/constants/app_assets.dart';
import '../../core/constants/app_icons.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../models/app_models.dart';

abstract final class MockContent {
  static const userName = 'Amber';

  static const onboarding = [
    OnboardingItem(
      title: 'Life gets\nbetter when\nyou do.',
      subtitle: 'A space to reset, reflect, and return to yourself.',
      caption: 'ground',
      icon: AppIcons.aiGuidance,
      accentColor: AppColors.sage,
    ),
    OnboardingItem(
      title: 'Small shifts.\nReal change.',
      subtitle:
          'Gentle prompts, science-backed resets, and a community that gets it.',
      caption: 'clarity',
      icon: AppIcons.resets,
      accentColor: AppColors.warmIvory,
    ),
    OnboardingItem(
      title: 'You already\nknow the way.',
      subtitle: 'Resora helps you hear yourself more clearly.',
      caption: 'restore',
      icon: AppIcons.journal,
      accentColor: AppColors.softBlueGrey,
    ),
  ];

  static const goals = [
    GoalOption(
      title: 'Calm down quickly',
      subtitle: 'Fast tools for overwhelming moments',
    ),
    GoalOption(
      title: 'Handle parenting stress',
      subtitle: 'Practical support for hard family moments',
    ),
    GoalOption(
      title: 'Think more clearly',
      subtitle: 'Reset spiraling thoughts and move forward',
    ),
    GoalOption(
      title: 'Reflect without overthinking',
      subtitle: 'Simple journaling after the moment passes',
    ),
  ];

  static const quickActions = [
    QuickActionItem(
      title: 'Gentle Resets',
      subtitle: 'Regulate first',
      icon: AppIcons.resets,
      accentColor: AppColors.primary,
      route: AppRoutes.resets,
    ),
    QuickActionItem(
      title: 'Quiet the Noise',
      subtitle: 'Audio support',
      icon: AppIcons.noise,
      accentColor: AppColors.success,
      route: AppRoutes.noise,
    ),
    QuickActionItem(
      title: 'Rehearse the Moment',
      subtitle: 'Practice the script',
      icon: AppIcons.rehearse,
      accentColor: AppColors.surface,
      route: AppRoutes.rehearse,
    ),
  ];

  static const spaces = [
    QuickActionItem(
      title: 'Gentle Resets',
      subtitle: 'Breath, grounding, step away',
      icon: AppIcons.resets,
      accentColor: AppColors.primary,
      route: AppRoutes.resets,
      imagePath: AppAssets.spaceGarden,
    ),
    QuickActionItem(
      title: 'Quiet the Noise',
      subtitle: 'Ambient audio and guided calm',
      icon: AppIcons.noise,
      accentColor: AppColors.success,
      route: AppRoutes.noise,
      imagePath: AppAssets.spaceRoom,
    ),
    QuickActionItem(
      title: 'Rehearse the Moment',
      subtitle: 'Scripts for the hard part',
      icon: AppIcons.rehearse,
      accentColor: AppColors.terracotta,
      route: AppRoutes.rehearse,
      imagePath: AppAssets.spaceMountain,
    ),
    QuickActionItem(
      title: 'Journal',
      subtitle: 'Reflect after you reset',
      icon: AppIcons.journal,
      accentColor: AppColors.surface,
      route: AppRoutes.journal,
      imagePath: AppAssets.homeJournalBed,
    ),
    QuickActionItem(
      title: 'Key Terms',
      subtitle: 'Plain-language definitions',
      icon: AppIcons.terms,
      accentColor: AppColors.success,
      route: AppRoutes.terms,
      imagePath: AppAssets.homeComingSoonFlower,
    ),
  ];

  static const supportCards = [
    SupportCardItem(
      category: 'Transitions',
      title: 'My child melts down every time we leave the playground.',
      footer: 'families relate',
    ),
    SupportCardItem(
      category: 'Sleep',
      title: 'My child refuses bedtime every night.',
      footer: 'families relate',
    ),
    SupportCardItem(
      category: 'Aggression',
      title: 'My child hits their sibling when upset.',
      footer: 'families relate',
    ),
    SupportCardItem(
      category: 'Routines',
      title: 'My child refuses to brush their teeth.',
      footer: 'families relate',
    ),
    SupportCardItem(
      category: 'Separation',
      title: 'My child hides when it is time to go.',
      footer: 'families relate',
    ),
    SupportCardItem(
      category: 'School',
      title: 'My child shuts down when I ask about the day.',
      footer: 'families relate',
    ),
  ];

  static const dailyAffirmation =
      'Calm is a practice, not a personality trait.';

  static const homePrimary = HomeSnippet(
    label: 'Help Me Now',
    title: 'Let’s slow this down.',
    body:
        'Start with one clear next step. Talk to Resora, try a reset, or rehearse what to say.',
  );

  static const recentJournal = JournalEntry(
    title: 'After the bedtime scramble',
    preview:
        'I lowered my voice first. That changed the room faster than another explanation would have.',
    date: 'Yesterday',
    wordCount: 64,
    prompt: 'What helped more than I expected today?',
  );

  static const suggestedPrompts = [
    "I'm overwhelmed",
    'I need clarity',
    'I need to vent',
  ];

  static const chatMessages = <ChatMessageModel>[];

  static const journalPrompts = [
    JournalPrompt(
      category: 'clarity',
      prompt:
          'What has been on your mind the most this week that you haven\'t said out loud to anyone?',
    ),
    JournalPrompt(
      category: 'release',
      prompt:
          'What are you still carrying that you were supposed to let go of months ago?',
    ),
    JournalPrompt(
      category: 'connect',
      prompt:
          'Who have you been showing up for lately? Who has been showing up for you?',
    ),
    JournalPrompt(
      category: 'ground',
      prompt: 'Where in your body do you feel the most tension right now?',
    ),
    JournalPrompt(
      category: 'restore',
      prompt: 'What would a genuinely restful day look like for you this week?',
    ),
  ];

  static const journalEntries = [
    JournalEntry(
      title: 'After school pickup',
      preview:
          'I needed less talking and more space. The reset worked once I stopped trying to fix everything at once.',
      date: 'Today',
      wordCount: 91,
      prompt: 'What helped?',
    ),
    JournalEntry(
      title: 'The text I almost sent',
      preview:
          'I drafted the message, waited ten minutes, and said less. That helped more than explaining every feeling.',
      date: 'Yesterday',
      wordCount: 57,
      prompt: 'What do I need next?',
    ),
    JournalEntry(
      title: 'Before bedtime',
      preview:
          'The room settled faster when I changed my tone instead of repeating the instruction.',
      date: 'Tuesday',
      wordCount: 73,
      prompt: 'What felt heavier than it looked?',
    ),
  ];

  static const resetOptions = [
    ResetOption(
      category: 'ground',
      title: 'Breath reset',
      subtitle: 'A guided inhale and exhale loop to slow the body down.',
      duration: '2 min',
      icon: AppIcons.resets,
      audioPath: AppAssets.resetBreathReset,
      imagePath: AppAssets.archway,
    ),
    ResetOption(
      category: 'release',
      title: 'Tension drop',
      subtitle: 'A slow body scan to release what you are holding right now.',
      duration: '3 min',
      icon: AppIcons.resets,
      audioPath: AppAssets.resetStepAway,
      imagePath: AppAssets.spaceGarden,
    ),
    ResetOption(
      category: 'clarity',
      title: 'One clear thought',
      subtitle: 'A simple prompt sequence to settle a busy or scattered mind.',
      duration: '4 min',
      icon: AppIcons.resets,
      audioPath: AppAssets.resetBoxBreath,
      imagePath: AppAssets.splashWaterfall,
    ),
    ResetOption(
      category: 'connect',
      title: 'Soften the posture',
      subtitle:
          'A reset for when you feel closed off or guarded around others.',
      duration: '3 min',
      icon: AppIcons.resets,
      audioPath: AppAssets.resetGroundFiveFourThreeTwoOne,
      imagePath: AppAssets.curtainLight,
    ),
    ResetOption(
      category: 'restore',
      title: 'Full pause',
      subtitle: 'Permission to do absolutely nothing for a few minutes.',
      duration: '5 min',
      icon: AppIcons.resets,
      audioPath: AppAssets.resetColdWater,
      imagePath: AppAssets.splashLivingRoom,
    ),
  ];

  static const audioTracks = [
    AudioTrack(
      title: 'Soft rain on leaves',
      category: 'nature',
      description:
          'Steady sound for nervous-system downshift. Let the rhythm of rain do the work your mind has been trying to do.',
      duration: '8 min',
      assetPath: AppAssets.ambientSoftRain,
      imagePath: AppAssets.splashWaterfall,
    ),
    AudioTrack(
      title: 'Brown noise for the background',
      category: 'brown noise',
      description:
          'Mask the noise and quiet the edges. Brown noise sits lower than white — warmer, less harsh.',
      duration: '20 min',
      assetPath: AppAssets.ambientBrownNoise,
      imagePath: AppAssets.spaceRoom,
    ),
    AudioTrack(
      title: 'Five minute guided exhale',
      category: 'guided',
      description:
          'Voice-led support for the first few minutes. You don\'t need to do anything except follow the breath.',
      duration: '5 min',
      assetPath: AppAssets.guidedExhale,
      imagePath: AppAssets.archway,
    ),
    AudioTrack(
      title: 'Still water visualization',
      category: 'visualization',
      description:
          'A short guided image to bring mental clarity when everything feels murky.',
      duration: '7 min',
      assetPath: AppAssets.guidedParentingCalm,
      imagePath: AppAssets.curtainLight,
    ),
  ];

  static const normalTopics = [
    NormalTopicItem(
      tab: 'evening stress',
      question: 'Is it normal to feel angry right before bed?',
      expertAnswer:
          'This is one of the most commonly felt moments in the evening. The transition from doing to stopping is harder for some nervous systems than others — and anger is often what exhaustion looks like.',
      metoo: 1204,
      voices: [
        'Yes. Every single night for months. I started doing 10 slow breaths before I even walked into my bedroom and it changed everything.',
        'I think it\'s the transition. The day is winding down but your body hasn\'t gotten the message yet.',
        'I thought I was just a bad person. Turns out it\'s a nervous system thing. That reframe helped more than anything.',
      ],
    ),
    NormalTopicItem(
      tab: 'overwhelm',
      question: 'I feel like I\'m behind on everything, always.',
      expertAnswer:
          'That feeling of perpetual lateness isn\'t a character flaw — it\'s often a sign of a nervous system that never fully downshifts. The catching up feeling can outlast the actual workload by days.',
      metoo: 3871,
      voices: [
        'I started asking: behind compared to what? Usually there\'s no real answer. It helped.',
        'This is me every Sunday. I\'ve started calling it \'the lag\' — it helps to name it.',
      ],
    ),
    NormalTopicItem(
      tab: 'depletion',
      question:
          'Sometimes I just need everyone to stop needing things from me.',
      expertAnswer:
          'This isn\'t a failure of love or care. It\'s a signal that your capacity has run out and your body is requesting a refill. Wanting space isn\'t selfish — it\'s information.',
      metoo: 2109,
      voices: [
        'This sentence made me cry the first time I read it. I thought I was the only one.',
        'I had to learn that this feeling is a boundary my body sets before I set it consciously.',
      ],
    ),
    NormalTopicItem(
      tab: 'low mood',
      question:
          'I don\'t know why I feel sad when nothing is technically wrong.',
      expertAnswer:
          'Emotions don\'t always have a clear cause. Sometimes sadness is depletion. Sometimes it\'s the body processing something slower than the mind. The absence of an obvious reason doesn\'t make the feeling less real.',
      metoo: 4430,
      voices: [
        'I started calling this \'weather\' instead of \'why.\' It passes. You don\'t have to explain it.',
        'This question opened up a whole therapy journey for me. You\'re not broken for asking it.',
      ],
    ),
  ];

  static const affirmations = [
    AffirmationItem(
      category: 'Daily',
      text: dailyAffirmation,
      duration: 'Morning reminder',
      isSaved: true,
    ),
    AffirmationItem(
      category: 'Parenting Calm',
      text: 'You do not need to match the chaos to lead the moment.',
      duration: 'Midday reminder',
    ),
    AffirmationItem(
      category: 'Evening Reset',
      text: 'Less pressure. One clear next step.',
      duration: 'Evening reminder',
      isPremium: true,
    ),
  ];

  static const mindfulnessTabs = ['Nature', 'Noise', 'Guided'];

  static const mindfulnessSessions = [
    MindfulnessSession(
      title: 'Soft rain on leaves',
      subtitle: 'Nature audio for immediate downshift',
      length: '18 min',
      type: 'Nature',
      color: AppColors.success,
      audioPath: AppAssets.ambientSoftRain,
      imagePath: AppAssets.splashWaterfall,
    ),
    MindfulnessSession(
      title: 'Brown noise for the background',
      subtitle: 'Frequency-based masking for focus and calm',
      length: '45 min',
      type: 'Noise',
      color: AppColors.surface,
      audioPath: AppAssets.ambientBrownNoise,
      imagePath: AppAssets.spaceRoom,
    ),
    MindfulnessSession(
      title: 'Five-minute guided exhale',
      subtitle: 'A short guided audio-led reset',
      length: '5 min',
      type: 'Guided',
      color: AppColors.terracotta,
      audioPath: AppAssets.guidedExhale,
      imagePath: AppAssets.archway,
    ),
    MindfulnessSession(
      title: 'Parenting calm visualization',
      subtitle: 'A future-focused guided audio session',
      length: '9 min',
      type: 'Guided',
      color: AppColors.primary,
      isPremium: true,
      audioPath: AppAssets.guidedParentingCalm,
      imagePath: AppAssets.curtainLight,
    ),
  ];

  static const rehearsalScenarios = [
    RehearsalScenario(
      title: 'Talking to my partner after a hard night',
      category: 'Connect',
      reframe:
          'You do not need a perfect explanation. You need a clear sentence.',
      script:
          '“I was overloaded and I do not want to keep talking at that level. Can we try this again more calmly tonight?”',
      steps: [
        'Start with one sentence, not the whole story.',
        'Name what you need next.',
        'Stop after the ask is clear.',
      ],
      audioPath: AppAssets.rehearsePartnerAfterHardNight,
      imagePath: AppAssets.curtainLight,
    ),
    RehearsalScenario(
      title: 'Asking for what I need at work',
      category: 'Clarity',
      reframe: 'Not a demand. Not an apology. Just a clear and honest ask.',
      script:
          '“I need a little clarity on priorities so I can focus on the right next step.”',
      steps: [
        'Name what you need directly.',
        'Keep the request specific.',
        'Pause before over-explaining.',
      ],
      audioPath: AppAssets.rehearseHardConversationWork,
      imagePath: AppAssets.splashWaterfall,
    ),
    RehearsalScenario(
      title: 'Setting a limit with someone close',
      category: 'Release',
      reframe: 'You can hold your boundary without holding your breath.',
      script:
          '“I care about this, and I need to pause here for now. I can come back when I have more room.”',
      steps: [
        'Lead with care and limit.',
        'Keep it one clear sentence.',
        'Stop before you justify.',
      ],
      audioPath: AppAssets.rehearseSettingLimit,
      imagePath: AppAssets.spaceGarden,
    ),
    RehearsalScenario(
      title: 'Re-entering a room after stepping away',
      category: 'Ground',
      reframe: 'You do not need to explain why you left. You just return.',
      script:
          '“I stepped out to reset. I\'m back and ready to continue calmly.”',
      steps: [
        'Exhale before speaking.',
        'Say one steady line.',
        'Keep your pace slow.',
      ],
      audioPath: AppAssets.rehearseAskForNeed,
      imagePath: AppAssets.archway,
    ),
    RehearsalScenario(
      title: 'Saying no without explaining yourself',
      category: 'Restore',
      reframe: 'A complete sentence. No footnotes required.',
      script: '“I can\'t commit to that right now.”',
      steps: [
        'Say no plainly.',
        'Do not add extra reasons.',
        'Hold the pause after speaking.',
      ],
      audioPath: AppAssets.rehearseRepairAfterTemper,
      imagePath: AppAssets.splashLivingRoom,
    ),
  ];

  static const qas = [
    QaItem(
      question: 'What do I do when I feel myself escalating with my child?',
      answer:
          'Slow your body first. Unclench your jaw. Lower your voice. Shorten what you say. Regulation works better than more explanation in that moment.',
      category: 'Parenting',
    ),
    QaItem(
      question: 'How do I handle work stress that follows me home?',
      answer:
          'Create a transition on purpose. Before you shift roles, do one clear closing action: close the laptop, exhale, and name the next task for tomorrow.',
      category: 'Work Stress',
    ),
    QaItem(
      question: 'How do I stop over-explaining myself in conflict?',
      answer:
          'Lead with the point, not the backstory. Most conflict gets worse when you keep adding detail after the message is already clear.',
      category: 'Relationships',
    ),
    QaItem(
      question: 'Can I get a custom answer for my exact situation?',
      answer:
          'Premium unlocks expanded support and custom AI-guided help when the pre-written library is not enough.',
      category: 'Premium',
      isPremium: true,
    ),
  ];

  static const keyTerms = [
    KeyTermItem(
      term: 'Regulation',
      definition:
          'Getting your body and mind back into a steadier state. When you regulate, you are not suppressing — you are giving your nervous system a way through the moment.',
    ),
    KeyTermItem(
      term: 'Window of Tolerance',
      definition:
          'The space where you can feel your feelings without being overwhelmed by them. Too little stimulation and you go numb. Too much and you spiral.',
    ),
    KeyTermItem(
      term: 'Co-regulation',
      definition:
          'The way steadiness moves between people. Being near someone grounded can help settle your own nervous system.',
    ),
    KeyTermItem(
      term: 'Rumination',
      definition:
          'Replaying a thought or scenario on repeat without it moving forward. It feels like problem-solving, but it is usually the mind stuck.',
    ),
    KeyTermItem(
      term: 'Nervous System Reset',
      definition:
          'Any action that communicates safety to your physiology. Slow breath, cold water, or a walk can help shift state.',
    ),
  ];

  static const communityPosts = [
    CommunityPost(
      author: 'Maya',
      role: 'Parent of two',
      title: 'I kept the limit and lowered my voice.',
      preview:
          'That changed the whole bedtime tone faster than another explanation would have.',
      category: 'Daily Wins',
      likes: 18,
      comments: 4,
    ),
    CommunityPost(
      author: 'Elena',
      role: 'Working mom',
      title: 'A two-minute pause helped more than pushing through.',
      preview: 'I stepped away before answering and came back much clearer.',
      category: 'Mindfulness',
      likes: 11,
      comments: 3,
    ),
    CommunityPost(
      author: 'Nora',
      role: 'Parenting through transitions',
      title: 'What do you say when pickup turns into a meltdown?',
      preview: 'I want one line I can repeat without escalating the moment.',
      category: 'Questions',
      likes: 9,
      comments: 6,
    ),
  ];

  static const profileOptions = [
    ProfileOption(
      label: 'Subscription',
      icon: AppIcons.premium,
      route: AppRoutes.subscription,
    ),
    ProfileOption(
      label: 'Privacy policy',
      icon: AppIcons.privacy,
      route: AppRoutes.privacyPolicy,
    ),
    ProfileOption(
      label: 'Help & support',
      icon: AppIcons.help,
      route: AppRoutes.helpSupport,
    ),
    ProfileOption(
      label: 'Log out',
      icon: AppIcons.logout,
      route: AppRoutes.welcome,
    ),
  ];

  static const premiumPlans = [
    PremiumPlan(
      title: 'Monthly',
      price: '\$11.99',
      caption: 'Flexible access to every space and unlimited chat',
      highlight: false,
    ),
    PremiumPlan(
      title: 'Yearly',
      price: '\$84.99',
      caption: 'Best value with a 7-day trial and full premium access',
      highlight: true,
    ),
  ];

  static const categories = [
    'All',
    'Parenting',
    'Emotions',
    'Relationships',
    'Work Stress',
    'Body / Regulation',
  ];
}
