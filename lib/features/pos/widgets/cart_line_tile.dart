import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'qty_stepper_field.dart';

/// One cart row: name/category header + delete button, then a 3-column
/// Qty(stepper + editable input) / Rate(input) / Line-total(readonly) row —
/// matches the "Current Sale" cart item layout in `PosTerminal.jsx`.
class CartLineTile extends StatelessWidget {
  final String name;
  final String category;
  final double qty;
  final double rate;
  final double lineTotal;
  final String rateLabel;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onRateChanged;
  final VoidCallback onRemove;

  const CartLineTile({
    super.key,
    required this.name,
    required this.category,
    required this.qty,
    required this.rate,
    required this.lineTotal,
    this.rateLabel = 'Rate',
    required this.onIncrement,
    required this.onDecrement,
    required this.onQtyChanged,
    required this.onRateChanged,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(fontSize: 11, letterSpacing: 0.4, color: AppColors.textFaint),
                    ),
                  ],
                ),
              ),
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
              Expanded(
                child: _labeledColumn(
                  'Qty',
                  QtyStepperField(
                    qty: qty,
                    fieldWidth: 56,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                    onQtyChanged: onQtyChanged,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: _labeledColumn(
                  rateLabel,
                  SizedBox(
                    height: 40,
                    child: TextFormField(
                      initialValue: rate.toStringAsFixed(2),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 6)),
                      onChanged: (value) => onRateChanged(double.tryParse(value) ?? rate),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: _labeledColumn(
                  'Total',
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                    child: Text(lineTotal.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labeledColumn(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

}
