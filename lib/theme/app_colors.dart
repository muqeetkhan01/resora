import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF145C4F);
  static const Color canvas = Color(0xFFFAFBF9);
  static const Color surface = Color(0xFFF1F4F8);
  static const Color warmDark = Color(0xFF4A342B);
  static const Color terracotta = Color(0xFFC4735A);

  static const Color text = Color(0xFF2D2D2D);
  static const Color muted = Color(0xFF8A8A8A);
  static const Color line = Color(0xFFE0E4E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFFAAAAAA);
  static const Color success = Color(0xFF3A7D6F);
  static const Color error = Color(0xFFB85C5C);
  static const Color shadow = Color(0x0F000000);

  static const Color darkBackground = Color(0xFF2B1F1A);
  static const Color darkSurface = Color(0xFF3B2D27);
  static const Color darkText = Color(0xFFF1EDE8);
  static const Color darkPrimary = Color(0xFF5B9B8C);

  static const Color shell = white;
  static const Color card = white;
  static const Color cardStrong = surface;
  static const Color peach = Color(0xFFE7D8CF);
  static const Color blush = Color(0xFFEFD8D2);
  static const Color sage = Color(0xFFD8E6DE);
  static const Color gold = Color(0xFFD8B86A);
  static const Color ink = text;
  static const Color premium = terracotta;

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [white, canvas, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dawnGradient = backgroundGradient;
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [terracotta, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient calmGradient = LinearGradient(
    colors: [canvas, white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient terracottaGlow = LinearGradient(
    colors: [terracotta, Color(0x00FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
