import 'package:flutter/material.dart';

/// Colors extracted directly from `PosTerminal.jsx` (Tailwind classes → hex),
/// kept as named roles so screens never hardcode a hex value.
class AppColors {
  AppColors._();

  // Background gradient behind the main POS card.
  static const gradientStart = Color(0xFF6EA8FF);
  static const gradientMid = Color(0xFF587BD8);
  static const gradientEnd = Color(0xFF7B61BD);

  // Dark section bars.
  static const headerDark = Color(0xFF284457);
  static const sectionDark = Color(0xFF2E495C);
  static const headerIconCircle = Color(0xFF19A7E0);

  // Primary / success.
  static const success = Color(0xFF10B981); // emerald-500
  static const successActive = Color(0xFF34D399); // emerald-400

  // Secondary / info.
  static const info = Color(0xFF0EA5E9); // sky-500
  static const infoActive = Color(0xFF38BDF8); // sky-400

  // Danger.
  static const danger = Color(0xFFEF4444); // rose-500
  static const dangerDark = Color(0xFFDC2626); // rose-600
  static const clearRed = Color(0xFFF5483C);

  // Tertiary / purchase-return.
  static const warning = Color(0xFFF59E0B); // amber-500
  static const warningDark = Color(0xFFD97706); // amber-600

  static const share = Color(0xFFA855F7); // violet-500
  static const dashboardDark = Color(0xFF111827); // slate-900

  // Surfaces.
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF8FAFC); // slate-50
  static const surfaceTotals = Color(0xFFF1F5F9); // slate-100

  // Tinted backgrounds.
  static const successTint = Color(0xFFF0FDF4); // emerald-50
  static const dangerTint = Color(0xFFFEF2F2); // rose-50
  static const warningTint = Color(0xFFFFFBEB); // amber-50
  static const infoTint = Color(0xFFF0F9FF); // sky-50

  // Text.
  static const textPrimary = Color(0xFF1E293B); // slate-800
  static const textSecondary = Color(0xFF334155); // slate-700
  static const textTertiary = Color(0xFF475569); // slate-600
  static const textMuted = Color(0xFF64748B); // slate-500
  static const textFaint = Color(0xFF94A3B8); // slate-400
  static const textOnDarkMuted = Color(0xFFE2E8F0); // slate-200

  // Borders.
  static const border = Color(0xFFE2E8F0); // slate-200
  static const borderSuccess = Color(0xFFD1FAE5); // emerald-200
  static const borderInfo = Color(0xFF7DD3FC); // sky-300
  static const borderInfoActive = Color(0xFF38BDF8); // sky-400
  static const borderDanger = Color(0xFFFECDD3); // rose-200
  static const borderDangerActive = Color(0xFFF87171); // rose-400
  static const borderWarning = Color(0xFFFDE68A); // amber-200
  static const borderWarningActive = Color(0xFFFBBF24); // amber-400

  static const overlayScrim = Color(0xB2020617); // slate-950/70
}
