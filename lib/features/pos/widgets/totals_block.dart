import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Subtotal: -> VAT: -> Delivery Charge: (editable, sell only) -> divider ->
/// Total Amount:, as plain rows with no boxed background — matches the web
/// app's totals section, which sits directly on the page.
class TotalsBlock extends StatelessWidget {
  final double subtotal;
  final double taxTotal;
  final double? deliveryCharge;
  final ValueChanged<double>? onDeliveryChanged;
  final double grandTotal;
  final String? totalLabel;

  const TotalsBlock({
    super.key,
    required this.subtotal,
    required this.taxTotal,
    this.deliveryCharge,
    this.onDeliveryChanged,
    required this.grandTotal,
    this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(AppLocalizations.of(context)!.totalsBlockSubtotalLabel, 'NPR ${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: AppSpacing.field),
        _row(AppLocalizations.of(context)!.totalsBlockVatLabel, 'NPR ${taxTotal.toStringAsFixed(2)}'),
        if (deliveryCharge != null) ...[
          const SizedBox(height: AppSpacing.field),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.totalsBlockDeliveryChargeLabel, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
              SizedBox(
                width: 90,
                height: 32,
                child: TextFormField(
                  initialValue: deliveryCharge!.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  onChanged: (v) => onDeliveryChanged?.call(double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.field),
          child: Divider(height: 1, color: AppColors.border),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${totalLabel ?? AppLocalizations.of(context)!.totalsBlockTotalAmountLabel}:',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            Text(
              'NPR ${grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}
