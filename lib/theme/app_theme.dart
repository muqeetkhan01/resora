import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    final heading = GoogleFonts.cormorantGaramondTextTheme();
    final body = GoogleFonts.merriweatherTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.terracotta,
        surface: AppColors.white,
        onSurface: AppColors.text,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: heading.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.05,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        displayMedium: heading.displayMedium?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.08,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        headlineLarge: heading.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.12,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        headlineMedium: heading.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.15,
          color: AppColors.primary,
        ),
        titleLarge: heading.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.15,
          color: AppColors.primary,
        ),
        titleMedium: body.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
        ),
        bodyLarge: body.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.7,
          color: AppColors.text,
        ),
        bodyMedium: body.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.7,
          color: AppColors.muted,
        ),
        bodySmall: body.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: AppColors.muted,
        ),
        labelLarge: body.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        labelMedium: body.labelMedium?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      cardTheme: CardTheme(
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
        hintStyle: body.bodyMedium?.copyWith(color: AppColors.placeholder),
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
