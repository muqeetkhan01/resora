import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    const radius = Radius.circular(24);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.success,
        secondary: AppColors.gold,
        surface: AppColors.shell,
        onSurface: AppColors.ink,
      ),
    );

    return base.copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(radius),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardStrong,
        selectedColor: AppColors.success,
        disabledColor: AppColors.cardStrong,
        secondarySelectedColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.line),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    const display = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 1.08,
      letterSpacing: -0.9,
      color: AppColors.ink,
    );

    const headline = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.16,
      letterSpacing: -0.4,
      color: AppColors.ink,
    );

    const title = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.2,
      color: AppColors.ink,
    );

    const body = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: AppColors.ink,
    );

    const label = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: AppColors.muted,
    );

    return base.copyWith(
      displayLarge: display,
      displayMedium: headline.copyWith(fontSize: 28),
      headlineLarge: headline,
      headlineMedium: headline.copyWith(fontSize: 22),
      titleLarge: title,
      titleMedium: title.copyWith(fontSize: 16),
      bodyLarge: body,
      bodyMedium: body.copyWith(fontSize: 14, color: AppColors.muted),
      bodySmall: label.copyWith(fontSize: 12),
      labelLarge: label.copyWith(color: AppColors.ink),
      labelMedium: label,
    );
  }
}
