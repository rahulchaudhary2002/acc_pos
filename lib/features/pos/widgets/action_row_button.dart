import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// One button in the Sell/Buy action row (Cash Sale / Customer Sale / Sales
/// Return, or New Purchase / Purchase Return): icon, bold label, small
/// subtitle caption — filled when active, outlined slate when inactive.
class ActionRowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool active;
  final Color activeColor;
  final Color activeBorderColor;
  final VoidCallback onTap;

  const ActionRowButton({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.active,
    required this.activeColor,
    required this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.field, vertical: AppSpacing.card),
        decoration: BoxDecoration(
          color: active ? activeColor : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? activeBorderColor : AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: active ? Colors.white : activeColor),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: active ? Colors.white.withValues(alpha: 0.85) : AppColors.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}
