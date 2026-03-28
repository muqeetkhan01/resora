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
    required this.moods,
  });

  final String title;
  final String preview;
  final String date;
  final List<String> moods;
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
  });

  final String label;
  final IconData icon;
  final String? trailing;
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
