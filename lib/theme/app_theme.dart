import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    TextStyle display({
      required double size,
      double height = 1.08,
      double letterSpacing = 0,
      FontStyle style = FontStyle.normal,
      Color color = AppColors.primary,
    }) {
      return GoogleFonts.jost(
        fontSize: size,
        fontWeight: FontWeight.w300,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: style,
        color: color,
      );
    }

    TextStyle ui({
      required double size,
      FontWeight weight = FontWeight.w400,
      double height = 1.6,
      double letterSpacing = 0.02,
      Color color = AppColors.text,
      FontStyle style = FontStyle.normal,
    }) {
      return GoogleFonts.jost(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
        fontStyle: style,
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.jost().fontFamily,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.terracotta,
        surface: AppColors.white,
        onSurface: AppColors.text,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: display(size: 48, height: 1.05),
        displayMedium: display(size: 34, height: 1.08),
        displaySmall: display(size: 28, height: 1.1, letterSpacing: 0),
        headlineLarge: display(size: 24, height: 1.12, letterSpacing: 0),
        headlineMedium: display(size: 22, height: 1.12, letterSpacing: 0),
        titleLarge: ui(
          size: 18,
          weight: FontWeight.w400,
          height: 1.35,
          letterSpacing: 0,
          color: AppColors.text,
        ),
        titleMedium: ui(
          size: 14,
          weight: FontWeight.w400,
          height: 1.45,
          letterSpacing: 0.02,
          color: AppColors.text,
        ),
        bodyLarge: ui(
          size: 13,
          weight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.02,
          color: AppColors.text,
        ),
        bodyMedium: ui(
          size: 13,
          weight: FontWeight.w400,
          height: 1.6,
          letterSpacing: 0.02,
          color: AppColors.muted,
        ),
        bodySmall: ui(
          size: 11,
          weight: FontWeight.w300,
          height: 1.6,
          letterSpacing: 0.12,
          color: AppColors.muted,
        ),
        labelLarge: ui(
          size: 13,
          weight: FontWeight.w500,
          height: 1.3,
          letterSpacing: 0.05,
          color: AppColors.primary,
        ),
        labelMedium: ui(
          size: 11,
          weight: FontWeight.w400,
          height: 1.35,
          letterSpacing: 0.14,
          color: AppColors.muted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.line),
        ),
        shadowColor: AppColors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        hintStyle: ui(
          size: 13,
          weight: FontWeight.w300,
          height: 1.6,
          letterSpacing: 0.02,
          color: AppColors.placeholder,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
