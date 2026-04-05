import 'package:flutter/material.dart';
import 'package:unibook/core/constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData darkTheme() => _buildTheme(Brightness.dark);

  static ThemeData lightTheme() => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? AppColors.primary : AppColors.lightAccent;
    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: primary,
      primary: primary,
      error: AppColors.error,
      surface: isDark ? AppColors.darkGlassCard : AppColors.lightGlassCard,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackgroundStart : AppColors.lightBackgroundStart,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkInputBg : Colors.white.withOpacity(0.35),
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkInputBorder : AppColors.lightGlassBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.primary : AppColors.lightAccent,
            width: 1.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkInputBorder : AppColors.lightGlassBorder,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkGlassCard : AppColors.lightGlassCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.darkBackgroundMid.withOpacity(0.9) : AppColors.lightAccent,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
