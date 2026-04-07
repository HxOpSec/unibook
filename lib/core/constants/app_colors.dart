import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary Purple Palette (University Branding)
  static const Color primary = Color(0xFF7B2CBF);
  static const Color primaryLight = Color(0xFFC77DFF);
  static const Color primaryDark = Color(0xFF5A189A);
  static const Color primaryDarker = Color(0xFF3C096C);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF808080);
  static const Color darkGray = Color(0xFF1F1F1F);
  static const Color darkBackground = Color(0xFF121212);

  // Background Gradients (light)
  static const Color lightBackgroundStart = Color(0xFFFAF7FF);
  static const Color lightBackgroundMid = Color(0xFFF3E9FF);
  static const Color lightBackgroundEnd = Color(0xFFECDDF8);

  // Background Gradients (dark)
  static const Color darkBackgroundStart = Color(0xFF0F0814);
  static const Color darkBackgroundMid = Color(0xFF1A0E28);
  static const Color darkBackgroundEnd = Color(0xFF2D1B4E);

  // Glass / card overlays
  static const Color darkGlassCard = Color(0x14FFFFFF);
  static const Color darkGlassBorder = Color(0x26FFFFFF);
  static const Color lightGlassCard = Color(0xB3FFFFFF);
  static const Color lightGlassBorder = Color(0x4D7B2CBF);

  // Text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xB3FFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A0030);
  static const Color lightTextSecondary = Color(0xB31A0030);

  // Input fields
  static const Color darkInputBg = Color(0x0DFFFFFF);
  static const Color darkInputBorder = Color(0x667B2CBF);

  // Legacy aliases kept for backward compatibility
  static const Color lightAccent = primary;
  static const Color darkAccentDeep = primaryDark;
  static const Color gold = primaryLight;
  static const Color surface = Color(0x1AFFFFFF);
  static const Color background = darkBackgroundStart;
  static const Color cardShadow = Color(0x14000000);
}
