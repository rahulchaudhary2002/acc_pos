import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Custom radius scale matching `PosTerminal.jsx`'s Tailwind `rounded-[Npx]`
/// utilities — these are not Material's default shapes, hence a dedicated class.
class AppRadius {
  AppRadius._();

  static const double outerCard = 32;
  static const double section = 28;
  static const double control = 16; // rounded-2xl
  static const double input = 12; // rounded-xl
  static const double full = 999;
}

/// Spacing scale (gap-6/4/3/2/1 equivalents).
class AppSpacing {
  AppSpacing._();

  static const double section = 24;
  static const double card = 16;
  static const double item = 12;
  static const double field = 8;
  static const double tight = 4;
}

class AppTextStyles {
  AppTextStyles._();

  static const pageTitle = TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white);
  static const sectionTitle = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const subsectionTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const ctaButton = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white);
  static const cardHeader = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const menuItem = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const tabLabel = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const helper = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static const tiny = TextStyle(fontSize: 11, color: AppColors.textFaint);
}

/// One consistent recipe for every colored button (filled ElevatedButton, or
/// an OutlinedButton used as a filled action like "Clear All"): the same
/// full color and text regardless of enabled/disabled state — no dimming,
/// no grey overlay, so a button looks identical either way.
class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle filled(Color color, {Color foreground = Colors.white}) {
    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(color),
      foregroundColor: WidgetStatePropertyAll(foreground),
      side: const WidgetStatePropertyAll(BorderSide.none),
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.info,
        primary: AppColors.info,
        secondary: AppColors.success,
        error: AppColors.danger,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.headerDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.info, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.filled(AppColors.info).copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control))),
          textStyle: const WidgetStatePropertyAll(AppTextStyles.ctaButton),
        ),
      ),
      // Matches elevatedButtonTheme's padding/shape/text size so an
      // OutlinedButton (e.g. "Cancel") sitting next to an ElevatedButton
      // (e.g. "Use Customer") renders at the same height, not visibly shorter.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.info,
          disabledForegroundColor: AppColors.info,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          side: const BorderSide(color: AppColors.textFaint),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
