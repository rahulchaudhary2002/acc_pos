import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Dismissible banner for business-rule errors (insufficient stock, no fiscal
/// year, etc.) that aren't tied to a specific form field.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.item),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card, vertical: AppSpacing.item),
      decoration: BoxDecoration(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.borderDanger),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerDark, size: 20),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.dangerDark, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.dangerDark),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}
