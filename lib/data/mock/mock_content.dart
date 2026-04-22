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
      title: 'Is This Normal?',
      subtitle: 'Quick reassurance',
      icon: AppIcons.isNormal,
      accentColor: AppColors.terracotta,
      route: AppRoutes.normal,
    ),
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
      title: 'Is This Normal?',
      subtitle: 'Short, reassuring answers',
      icon: AppIcons.isNormal,
      accentColor: AppColors.terracotta,
      route: AppRoutes.normal,
      imagePath: AppAssets.homeNormalStem,
    ),
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
    'I am close to snapping. What do I do right now?',
    'Give me a 2-minute reset.',
    'Help me script a hard conversation.',
  ];

  static const chatMessages = <ChatMessageModel>[];

  static const journalPrompts = [
    JournalPrompt(
      category: 'clarity',
      prompt: 'What felt heavier than it looked?',
    ),
    JournalPrompt(
      category: 'ground',
      prompt: 'Where did you feel most steady today?',
    ),
    JournalPrompt(
      category: 'release',
      prompt: 'What are you still carrying from yesterday?',
    ),
    JournalPrompt(
      category: 'connect',
      prompt: 'What do you wish someone had said to you today?',
    ),
    JournalPrompt(
      category: 'restore',
      prompt: 'What would feel restorative before the day ends?',
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
    ),
    ResetOption(
      category: 'release',
      title: 'Step away',
      subtitle: 'A short permission to pause before you respond to anything.',
      duration: '1 min',
      icon: AppIcons.isNormal,
    ),
    ResetOption(
      category: 'clarity',
      title: '5-4-3-2-1 ground',
      subtitle:
          'Bring yourself back to the room when your mind will not settle.',
      duration: '3 min',
      icon: AppIcons.close,
    ),
    ResetOption(
      category: 'ground',
      title: 'Box breath',
      subtitle: 'Four counts in, hold, four counts out.',
      duration: '4 min',
      icon: AppIcons.play,
    ),
    ResetOption(
      category: 'restore',
      title: 'Cold water reset',
      subtitle: 'A simple physical anchor when everything feels like too much.',
      duration: '1 min',
      icon: AppIcons.play,
    ),
  ];

  static const audioTracks = [
    AudioTrack(
      title: 'Soft rain on leaves',
      category: 'Nature',
      description: 'Steady sound for nervous-system downshift',
      duration: '1 min',
      assetPath: AppAssets.ambientSoftRain,
    ),
    AudioTrack(
      title: 'Brown noise for the background',
      category: 'Brown Noise',
      description: 'Mask the noise and quiet the edges',
      duration: '2 min',
      assetPath: AppAssets.ambientBrownNoise,
    ),
    AudioTrack(
      title: 'Five-minute guided exhale',
      category: 'Guided Meditation',
      description: 'Voice-led support for the first few minutes',
      duration: '1 min',
      assetPath: AppAssets.guidedExhale,
    ),
    AudioTrack(
      title: 'Parenting calm visualization',
      category: 'Visualizations',
      description: 'Future-focused calm before the next hard moment',
      duration: '1 min',
      assetPath: AppAssets.guidedParentingCalm,
      isPremium: true,
    ),
  ];

  static const normalTopics = [
    NormalTopicItem(
      tab: 'evening stress',
      question: 'Is it normal to feel angry right before bedtime?',
      expertAnswer:
          'Yes. End-of-day overload is common, especially when you have been carrying the weight of the day. Start with regulation, then decide what actually needs to happen tonight.',
      metoo: 1204,
      voices: [
        'I used to think something was wrong with me. Turns out I just needed ten minutes alone before the evening started.',
        'The angrier I felt, the more I realized I had not had a single moment to myself all day.',
        'What helped me was recognizing it as a signal, not a flaw.',
      ],
    ),
    NormalTopicItem(
      tab: 'overwhelm',
      question: 'Is it normal to feel like I can\'t do anything right?',
      expertAnswer:
          'Yes. When you are overwhelmed, your brain narrows its focus to threats, which can make everything feel like evidence of failure. It is a stress response, not the truth.',
      metoo: 980,
      voices: [
        'I kept waiting to feel competent. Eventually I realized that feeling was the overwhelm talking.',
        'Naming it as a stress response completely changed how I related to it.',
        'Once I stopped treating every mistake like proof, I could finally breathe again.',
      ],
    ),
    NormalTopicItem(
      tab: 'regulation',
      question: 'Is it normal to need silence just to feel okay?',
      expertAnswer:
          'Completely. Sensory and social input accumulate across the day. Needing quiet is not withdrawal. It can be exactly what helps your system settle.',
      metoo: 2341,
      voices: [
        'Silence is the only thing that actually works for me. I stopped apologizing for it.',
        'I used to feel guilty for not wanting to talk. Now I protect that quiet time on purpose.',
        'Even five minutes of silence in my car before going inside changed everything.',
      ],
    ),
    NormalTopicItem(
      tab: 'sleep',
      question: 'Is it normal to lie awake replaying everything?',
      expertAnswer:
          'Yes. A tired nervous system often keeps scanning long after the day is over. The goal is not to solve every thought tonight. It is to help your body feel safe enough to rest.',
      metoo: 1648,
      voices: [
        'My brain gets loudest the moment the house is finally quiet.',
        'The replay loop eased up once I stopped trying to finish every thought before bed.',
        'I needed a wind-down ritual, not more self-criticism.',
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
    ),
    MindfulnessSession(
      title: 'Brown noise for the background',
      subtitle: 'Frequency-based masking for focus and calm',
      length: '45 min',
      type: 'Noise',
      color: AppColors.surface,
    ),
    MindfulnessSession(
      title: 'Five-minute guided exhale',
      subtitle: 'A short guided audio-led reset',
      length: '5 min',
      type: 'Guided',
      color: AppColors.terracotta,
    ),
    MindfulnessSession(
      title: 'Parenting calm visualization',
      subtitle: 'A future-focused guided audio session',
      length: '9 min',
      type: 'Guided',
      color: AppColors.primary,
      isPremium: true,
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
    ),
    RehearsalScenario(
      title: 'Setting a limit with someone I care about',
      category: 'Release',
      reframe: 'Saying it clearly is not the same as saying it unkindly.',
      script:
          '“I care about this, and I need to stop here for tonight. I can come back to it when I have more room.”',
      steps: [
        'Keep the sentence short.',
        'Let the boundary be the message.',
        'Do not explain past the first clear line.',
      ],
    ),
    RehearsalScenario(
      title: 'Asking for what I actually need',
      category: 'Clarity',
      reframe: 'Most people cannot guess. Most people will help if you say it.',
      script:
          '“I do not need advice first. I need a little support and one clear next step.”',
      steps: [
        'Ask for the real need.',
        'Say it plainly.',
        'Pause before adding extra explanation.',
      ],
    ),
    RehearsalScenario(
      title: 'Repairing after I lost my temper',
      category: 'Connect',
      reframe: 'You do not have to be perfect. You have to show up.',
      script:
          '“I do not like how I handled that. I want to try again more gently.”',
      steps: [
        'Own your part without over-explaining.',
        'Say the repair line simply.',
        'Focus on the next interaction, not a perfect apology.',
      ],
    ),
    RehearsalScenario(
      title: 'Handling a hard conversation at work',
      category: 'Ground',
      reframe: 'Steady beats certain. You do not need all the answers.',
      script:
          '“I want to be thoughtful here. Let me answer the part I know, and I can follow up on the rest.”',
      steps: [
        'Slow your pace first.',
        'Answer what is clear.',
        'Leave room for a follow-up instead of forcing certainty.',
      ],
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
      definition: 'Getting your body and mind back into a steadier state.',
    ),
    KeyTermItem(
      term: 'Emotional flooding',
      definition:
          'The moment your system gets overwhelmed and clear thinking drops.',
    ),
    KeyTermItem(
      term: 'Co-regulation',
      definition:
          'Borrowing calm from another person’s steady tone, pace, or presence.',
    ),
    KeyTermItem(
      term: 'Sensory overload',
      definition:
          'When sound, touch, light, or activity stacks up faster than your system can process it.',
    ),
    KeyTermItem(
      term: 'Window of tolerance',
      definition:
          'The zone where you can think clearly enough to respond instead of react.',
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
