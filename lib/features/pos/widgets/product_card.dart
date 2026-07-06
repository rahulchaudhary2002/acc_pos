import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/product.dart';

/// One product tile in the picker grid — icon circle, name, price (sell) or
/// nothing (buy), stock text, "Out of Stock" pill when applicable.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showPrice;

  const ProductCard({super.key, required this.product, this.onTap, this.showPrice = true});

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.outOfStock;
    // Mirrors PosTerminal.jsx: the "Out of Stock" pill is informational only
    // — the button stays tappable so it can still be selected for a
    // purchase (which adds stock) or as a stock-level override; actual sale
    // stock validation happens server-side at checkout, not here.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.card),
        decoration: BoxDecoration(
          color: outOfStock ? AppColors.dangerTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: outOfStock ? AppColors.borderDanger : AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: AppColors.infoTint, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(
                product.isService ? Icons.build_outlined : Icons.local_gas_station,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: AppSpacing.field),
            Flexible(
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            if (showPrice) ...[
              const SizedBox(height: 4),
              Text(
                'Rs ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              product.trackInventory ? 'Stock: ${product.currentStock.toStringAsFixed(0)}' : 'Not tracked',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (outOfStock) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.dangerTint,
                  border: Border.all(color: AppColors.borderDanger),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dangerDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
