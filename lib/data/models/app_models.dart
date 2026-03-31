import 'package:flutter/material.dart';

class OnboardingItem {
  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.caption,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String caption;
  final IconData icon;
  final Color accentColor;
}

class QuickActionItem {
  const QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    this.routeArguments,
    this.premium = false,
    this.dashboardIndex,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final dynamic routeArguments;
  final bool premium;
  final int? dashboardIndex;
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });

  final String text;
  final bool isUser;
  final String time;
}

class JournalEntry {
  const JournalEntry({
    required this.title,
    required this.preview,
    required this.date,
    this.moods = const [],
    this.wordCount = 0,
    this.prompt,
  });

  final String title;
  final String preview;
  final String date;
  final List<String> moods;
  final int wordCount;
  final String? prompt;
}

class AffirmationItem {
  const AffirmationItem({
    required this.category,
    required this.text,
    required this.duration,
    this.isPremium = false,
    this.isSaved = false,
  });

  final String category;
  final String text;
  final String duration;
  final bool isPremium;
  final bool isSaved;
}

class MindfulnessSession {
  const MindfulnessSession({
    required this.title,
    required this.subtitle,
    required this.length,
    required this.type,
    required this.color,
    this.isPremium = false,
  });

  final String title;
  final String subtitle;
  final String length;
  final String type;
  final Color color;
  final bool isPremium;
}

class QaItem {
  const QaItem({
    required this.question,
    required this.answer,
    required this.category,
    this.isPremium = false,
  });

  final String question;
  final String answer;
  final String category;
  final bool isPremium;
}

class CommunityPost {
  const CommunityPost({
    required this.author,
    required this.role,
    required this.title,
    required this.preview,
    required this.category,
    required this.likes,
    required this.comments,
  });

  final String author;
  final String role;
  final String title;
  final String preview;
  final String category;
  final int likes;
  final int comments;
}

class ProfileOption {
  const ProfileOption({
    required this.label,
    required this.icon,
    this.trailing,
    this.route,
  });

  final String label;
  final IconData icon;
  final String? trailing;
  final String? route;
}

class PremiumPlan {
  const PremiumPlan({
    required this.title,
    required this.price,
    required this.caption,
    required this.highlight,
  });

  final String title;
  final String price;
  final String caption;
  final bool highlight;
}

class GoalOption {
  const GoalOption({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class ResetOption {
  const ResetOption({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
}

class AudioTrack {
  const AudioTrack({
    required this.title,
    required this.category,
    required this.description,
    required this.duration,
    this.isPremium = false,
  });

  final String title;
  final String category;
  final String description;
  final String duration;
  final bool isPremium;
}

class RehearsalScenario {
  const RehearsalScenario({
    required this.title,
    required this.category,
    required this.reframe,
    required this.script,
    required this.steps,
    this.isPremium = false,
  });

  final String title;
  final String category;
  final String reframe;
  final String script;
  final List<String> steps;
  final bool isPremium;
}

class KeyTermItem {
  const KeyTermItem({
    required this.term,
    required this.definition,
  });

  final String term;
  final String definition;
}

class HomeSnippet {
  const HomeSnippet({
    required this.label,
    required this.title,
    required this.body,
  });

  final String label;
  final String title;
  final String body;
}

class SupportCardItem {
  const SupportCardItem({
    required this.category,
    required this.title,
    required this.footer,
  });

  final String category;
  final String title;
  final String footer;
}
