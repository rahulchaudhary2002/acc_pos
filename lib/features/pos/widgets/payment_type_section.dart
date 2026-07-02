import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// "Payment Type" card from `PosTerminal.jsx`: Cash Sale / Credit Sale
/// (customer sales only) / Online Payment radios, with conditional
/// Remarks (cash) or Reference No. + Payment Note (online) fields.
class PaymentTypeSection extends StatelessWidget {
  final bool allowCredit;
  final String paymentMode;
  final ValueChanged<String> onPaymentModeChanged;
  final String remarks;
  final ValueChanged<String> onRemarksChanged;
  final String paymentReference;
  final ValueChanged<String> onPaymentReferenceChanged;
  final String paymentNote;
  final ValueChanged<String> onPaymentNoteChanged;

  const PaymentTypeSection({
    super.key,
    required this.allowCredit,
    required this.paymentMode,
    required this.onPaymentModeChanged,
    required this.remarks,
    required this.onRemarksChanged,
    required this.paymentReference,
    required this.onPaymentReferenceChanged,
    required this.paymentNote,
    required this.onPaymentNoteChanged,
  });

  /// Content only — no card/border of its own. This section lives inside the
  /// same white card as Current Sale/Totals (see `SellScreen`), not a
  /// separate floating box.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Type', style: AppTextStyles.cardHeader),
        const SizedBox(height: AppSpacing.item),
        _radioTile('cash', 'Cash Sale'),
        if (allowCredit) _radioTile('credit', 'Credit Sale'),
        _radioTile('online', 'Online Payment'),
        const SizedBox(height: AppSpacing.item),
        if (paymentMode == 'cash')
          TextField(
            controller: TextEditingController(text: remarks)..selection = TextSelection.collapsed(offset: remarks.length),
            onChanged: onRemarksChanged,
            decoration: const InputDecoration(labelText: 'Remarks', hintText: 'Optional remarks for this cash sale'),
          )
        else if (paymentMode == 'online')
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: paymentReference)
                    ..selection = TextSelection.collapsed(offset: paymentReference.length),
                  onChanged: onPaymentReferenceChanged,
                  decoration: const InputDecoration(labelText: 'Reference No.', hintText: 'Transaction ID / Ref. No.'),
                ),
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: paymentNote)..selection = TextSelection.collapsed(offset: paymentNote.length),
                  onChanged: onPaymentNoteChanged,
                  decoration: const InputDecoration(labelText: 'Payment Note', hintText: 'Wallet, bank, mobile number'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _radioTile(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: paymentMode,
      onChanged: (v) => onPaymentModeChanged(v!),
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      activeColor: AppColors.info,
    );
  }
}
