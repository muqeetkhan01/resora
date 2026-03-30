import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    final serif = GoogleFonts.merriweatherTextTheme();
    final sans = GoogleFonts.dmSansTextTheme();

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
        displayLarge: serif.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        displayMedium: serif.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        headlineLarge: serif.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0.2,
          color: AppColors.primary,
        ),
        headlineMedium: serif.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: AppColors.primary,
        ),
        titleLarge: serif.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: AppColors.primary,
        ),
        titleMedium: sans.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        bodyLarge: sans.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: AppColors.text,
        ),
        bodyMedium: sans.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.55,
          color: AppColors.muted,
        ),
        bodySmall: sans.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.muted,
        ),
        labelLarge: sans.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        labelMedium: sans.labelMedium?.copyWith(
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        shadowColor: AppColors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: sans.bodyMedium?.copyWith(color: AppColors.placeholder),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
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
