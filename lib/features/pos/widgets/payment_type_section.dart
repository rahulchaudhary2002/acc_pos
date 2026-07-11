import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

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
        Text(AppLocalizations.of(context)!.paymentTypeSectionHeader, style: AppTextStyles.cardHeader),
        const SizedBox(height: AppSpacing.item),
        _radioTile(context, 'cash', AppLocalizations.of(context)!.paymentTypeSectionCashSaleLabel),
        if (allowCredit) _radioTile(context, 'credit', AppLocalizations.of(context)!.paymentTypeSectionCreditSaleLabel),
        _radioTile(context, 'online', AppLocalizations.of(context)!.paymentTypeSectionOnlinePaymentLabel),
        const SizedBox(height: AppSpacing.item),
        if (paymentMode == 'cash')
          TextField(
            controller: TextEditingController(text: remarks)..selection = TextSelection.collapsed(offset: remarks.length),
            onChanged: onRemarksChanged,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.paymentTypeSectionRemarksLabel,
              hintText: AppLocalizations.of(context)!.paymentTypeSectionRemarksHint,
            ),
          )
        else if (paymentMode == 'online')
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: paymentReference)
                    ..selection = TextSelection.collapsed(offset: paymentReference.length),
                  onChanged: onPaymentReferenceChanged,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.paymentTypeSectionReferenceNoLabel,
                    hintText: AppLocalizations.of(context)!.paymentTypeSectionReferenceHint,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.field),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: paymentNote)..selection = TextSelection.collapsed(offset: paymentNote.length),
                  onChanged: onPaymentNoteChanged,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.paymentTypeSectionPaymentNoteLabel,
                    hintText: AppLocalizations.of(context)!.paymentTypeSectionPaymentNoteHint,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _radioTile(BuildContext context, String value, String label) {
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
