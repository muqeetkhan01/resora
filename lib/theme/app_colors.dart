import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFF7F1EA);
  static const Color shell = Color(0xFFFFFBF7);
  static const Color card = Color(0xFFFDF7F2);
  static const Color cardStrong = Color(0xFFF4E9DF);
  static const Color peach = Color(0xFFE9C5AF);
  static const Color blush = Color(0xFFDFA6A2);
  static const Color sage = Color(0xFFB7C7B0);
  static const Color gold = Color(0xFFCDAA64);
  static const Color ink = Color(0xFF2F2725);
  static const Color muted = Color(0xFF7E706A);
  static const Color line = Color(0xFFE8DDD3);
  static const Color success = Color(0xFF6E9A7B);
  static const Color premium = Color(0xFF8F6C3B);
  static const Color shadow = Color(0x1A533E2A);

  static const LinearGradient dawnGradient = LinearGradient(
    colors: [Color(0xFFFFFBF7), Color(0xFFF9F0E8), Color(0xFFF4E8E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFE6D2B0), Color(0xFFC89B60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFFEAE3D7), Color(0xFFF6EFE9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
