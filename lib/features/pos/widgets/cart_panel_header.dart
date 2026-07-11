import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Two-line dark header for the cart/purchase-summary panel: title row with
/// an icon, then "Items: X | Total: Rs Y" beneath it — matches
/// `PosTerminal.jsx`'s "Current Sale"/"Purchase Summary" panel header.
class CartPanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int itemCount;
  final double total;
  final Color background;

  const CartPanelHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.itemCount,
    required this.total,
    this.background = AppColors.sectionDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.control)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.field),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.cartPanelHeaderItemsTotalLabel(itemCount, total.toStringAsFixed(2)),
            style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
