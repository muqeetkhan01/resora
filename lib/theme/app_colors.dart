import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFF6FBF3);
  static const Color shell = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFEFB);
  static const Color cardStrong = Color(0xFFEEF6E8);
  static const Color peach = Color(0xFFF6E7AE);
  static const Color blush = Color(0xFFF9F1C9);
  static const Color sage = Color(0xFFCFE4C6);
  static const Color gold = Color(0xFFE1C85B);
  static const Color ink = Color(0xFF314237);
  static const Color muted = Color(0xFF738174);
  static const Color line = Color(0xFFDCE9D6);
  static const Color success = Color(0xFF6F9B68);
  static const Color premium = Color(0xFFC6A93B);
  static const Color shadow = Color(0x14385A32);

  static const LinearGradient dawnGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5FBF1), Color(0xFFFBF8E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFF4E183), Color(0xFFBBD889)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFFF4FAEE), Color(0xFFFFFBEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
