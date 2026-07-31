import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum StatusBadgeTone { success, warning, danger, neutral }

/// Small colored pill for a short status label (e.g. CBMS sync status),
/// generalized from the ad hoc `AppColors`-tinted containers already used
/// throughout the POS screens (see `others_screen.dart`).
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeTone tone;

  const StatusBadge({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (tone) {
      StatusBadgeTone.success => (AppColors.successTint, AppColors.success),
      StatusBadgeTone.warning => (AppColors.warningTint, AppColors.warningDark),
      StatusBadgeTone.danger => (AppColors.dangerTint, AppColors.dangerDark),
      StatusBadgeTone.neutral => (AppColors.surfaceTotals, AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
