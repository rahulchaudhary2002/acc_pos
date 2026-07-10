import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../utils/invoice_format_utils.dart';

/// One line item on the printed invoice — Sr./H.S. Code/Description/Qty/
/// Rate/Total Amt., matching the web receipt's table columns.
class InvoiceLineData {
  final String hsCode;
  final String description;
  final double qty;
  final double rate;
  final double total;
  final double taxRate;

  const InvoiceLineData({
    required this.hsCode,
    required this.description,
    required this.qty,
    required this.rate,
    required this.total,
    this.taxRate = 0,
  });
}

/// A label/value pair for the meta grid (`null` renders a blank cell so a
/// row can have just one field, mirroring gaps in the web's 3-col grid).
typedef MetaField = (String label, String value)?;

/// Shared "TAX INVOICE" layout — company header, meta grid, line-items
/// table, VAT summary, amount-in-words, and a signature block — used by
/// both the post-sale and post-purchase preview dialogs so the two stay
/// pixel-identical, matching the shared markup in `PosTerminal.jsx`.
class TaxInvoiceDocument extends StatelessWidget {
  final String companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyVatNo;
  final List<List<MetaField>> metaRows;
  final List<InvoiceLineData> items;
  final DateTime printedAt;
  final double taxable;
  final double nonTaxable;
  final double subtotal;
  final String vatRateLabel;
  final double tax;
  final double total;
  final String preparedBy;
  final String signatureRightLabel;
  final List<Widget> actions;

  const TaxInvoiceDocument({
    super.key,
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyVatNo,
    required this.metaRows,
    required this.items,
    required this.printedAt,
    required this.taxable,
    required this.nonTaxable,
    required this.subtotal,
    required this.vatRateLabel,
    required this.tax,
    required this.total,
    required this.preparedBy,
    required this.signatureRightLabel,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Text(companyName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if ((companyAddress ?? '').isNotEmpty)
              Text(companyAddress!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            if ((companyPhone ?? '').isNotEmpty)
              Text('Phone No : $companyPhone', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            if ((companyVatNo ?? '').isNotEmpty)
              Text('VAT # : $companyVatNo', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: AppSpacing.card),
        const Text(
          'TAX INVOICE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
        ),
        const SizedBox(height: AppSpacing.card),
        for (final row in metaRows) _metaRowPair(row),
        const SizedBox(height: AppSpacing.card),
        _itemsTable(),
        const SizedBox(height: AppSpacing.card),
        _totalsSection(),
        const SizedBox(height: AppSpacing.field),
        Text(amountToWords(total), style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        const SizedBox(height: AppSpacing.section),
        _signatureBlock(),
        const SizedBox(height: AppSpacing.section),
        Wrap(spacing: AppSpacing.field, runSpacing: AppSpacing.field, alignment: WrapAlignment.center, children: actions),
      ],
    );
  }

  Widget _metaRowPair(List<MetaField> row) {
    if (row.every((f) => f == null)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: row.isNotEmpty && row[0] != null ? _metaField(row[0]!) : const SizedBox.shrink()),
          const SizedBox(width: AppSpacing.field),
          Expanded(child: row.length > 1 && row[1] != null ? _metaField(row[1]!) : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _metaField((String, String) field) {
    final (label, value) = field;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        children: [
          TextSpan(text: '$label : '),
          TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _itemsTable() {
    return Table(
      border: TableBorder(
        top: const BorderSide(color: AppColors.textPrimary, width: 1.5),
        bottom: const BorderSide(color: AppColors.textPrimary, width: 1.5),
        horizontalInside: const BorderSide(color: AppColors.textPrimary, width: 0.75),
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.6),
        1: FlexColumnWidth(1.3),
        2: FlexColumnWidth(3),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1.2),
        5: FlexColumnWidth(1.3),
      },
      children: [
        const TableRow(children: [
          _InvoiceCell('Sr.', bold: true, align: TextAlign.center),
          _InvoiceCell('H.S. Code', bold: true),
          _InvoiceCell('Description', bold: true),
          _InvoiceCell('Qty.', bold: true, align: TextAlign.right),
          _InvoiceCell('Rate', bold: true, align: TextAlign.right),
          _InvoiceCell('Total Amt.', bold: true, align: TextAlign.right),
        ]),
        for (var i = 0; i < items.length; i++)
          TableRow(children: [
            _InvoiceCell('${i + 1}', align: TextAlign.center),
            _InvoiceCell(items[i].hsCode.isEmpty ? '-' : items[i].hsCode),
            _InvoiceCell(items[i].description),
            _InvoiceCell(_qty(items[i].qty), align: TextAlign.right),
            _InvoiceCell(items[i].rate.toStringAsFixed(2), align: TextAlign.right),
            _InvoiceCell(items[i].total.toStringAsFixed(2), align: TextAlign.right),
          ]),
      ],
    );
  }

  static String _qty(double qty) => qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2);

  Widget _totalsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.field),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.textPrimary, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _plainRow('Print Date/Time :', printDateTimeLabel(printedAt)),
                _plainRow('Nepali Date :', nepaliDateLabel(printedAt)),
                const SizedBox(height: AppSpacing.field),
                const Text('Original', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.card),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _summaryRow('Taxable :', taxable),
                _summaryRow('Non Taxable :', nonTaxable),
                _summaryRow('Sub Total :', subtotal),
                _summaryRow('Discount : 0 %', 0),
                _summaryRow(vatRateLabel.isEmpty ? 'VAT Amount :' : 'VAT Amount ($vatRateLabel) :', tax),
                _summaryRow('Net Total :', total, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text('$label $value', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(fontSize: bold ? 13 : 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value.toStringAsFixed(2), style: style),
        ],
      ),
    );
  }

  Widget _signatureBlock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _signatureColumn(preparedBy.isEmpty ? 'Prepared By' : preparedBy, 'Prepare By')),
        const SizedBox(width: AppSpacing.section),
        Expanded(child: _signatureColumn('', signatureRightLabel)),
      ],
    );
  }

  Widget _signatureColumn(String name, String label) {
    return Column(
      children: [
        SizedBox(height: 16, child: Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
        const Text('--------------------', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InvoiceCell extends StatelessWidget {
  final String text;
  final bool bold;
  final TextAlign align;

  const _InvoiceCell(this.text, {this.bold = false, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
      ),
    );
  }
}

/// Shared dialog chrome — an A5-receipt-like scrollable card, matching the
/// web modal's rounded white card on a dark scrim.
Future<void> showTaxInvoiceDialog(BuildContext context, {required Widget document}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.overlayScrim,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: SingleChildScrollView(child: document),
        ),
      ),
    ),
  );
}
