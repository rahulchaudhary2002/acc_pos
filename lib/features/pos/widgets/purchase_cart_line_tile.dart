import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'qty_stepper_field.dart';

/// Buy-cart row: qty stepper + editable qty input + unit cost input + line
/// total, no tax column (matches `/pos/buy`'s request shape, which has no
/// tax fields).
class PurchaseCartLineTile extends StatelessWidget {
  final String name;
  final double qty;
  final double unitCost;
  final double lineTotal;
  final bool unitCostEditable;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onUnitCostChanged;
  final VoidCallback onRemove;

  const PurchaseCartLineTile({
    super.key,
    required this.name,
    required this.qty,
    required this.unitCost,
    required this.lineTotal,
    this.unitCostEditable = true,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQtyChanged,
    required this.onUnitCostChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.item),
      padding: const EdgeInsets.all(AppSpacing.item),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.dangerTint, shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          Row(
            children: [
              QtyStepperField(
                qty: qty,
                fieldWidth: 56,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onQtyChanged: onQtyChanged,
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    initialValue: unitCost.toStringAsFixed(2),
                    enabled: unitCostEditable,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.purchaseCartLineUnitCostLabel,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (v) => onUnitCostChanged(double.tryParse(v) ?? unitCost),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      lineTotal.toStringAsFixed(2),
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
