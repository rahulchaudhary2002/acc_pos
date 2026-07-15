import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gas_cylinder_icon.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final outOfStock = product.outOfStock;
    final disabled = onTap == null;
    // The "Out of Stock" pill always renders so the card looks the same in
    // Sell and Buy; only Sell passes disableOutOfStock, which nulls onTap
    // and dims the card here so it reads as unselectable.
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
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
                child: product.isService
                    ? const Icon(Icons.build_outlined, color: AppColors.info)
                    : const GasCylinderIcon(size: 24, color: AppColors.cylinderRed),
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
                  'NPR ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                product.trackInventory
                    ? l10n.productCardStockLabel(product.currentStock.toStringAsFixed(0))
                    : l10n.productCardNotTracked,
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
                  child: Text(
                    l10n.productCardOutOfStock,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dangerDark),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
