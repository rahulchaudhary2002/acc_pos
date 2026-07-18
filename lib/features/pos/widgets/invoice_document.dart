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
  final double delivery;
  final double total;
  final String preparedBy;
  final String signatureRightLabel;
  final List<Widget> actions;
  final String title;

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
    this.delivery = 0,
    required this.total,
    required this.preparedBy,
    required this.signatureRightLabel,
    required this.actions,
    this.title = 'TAX INVOICE',
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Arial', color: AppColors.textPrimary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              // Printed exactly as stored — no forced upper-casing — matching
              // the physical receipt showing "Head Office", not "HEAD OFFICE".
              // The web receipt never prints phone/VAT in the header (dead
              // variables in its print template), so neither does this.
              Text(companyName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if ((companyAddress ?? '').isNotEmpty)
                Text(companyAddress!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: AppSpacing.field),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          _divider(),
          ..._metaFieldWidgets(),
          _divider(),
          _itemsTable(),
          _divider(),
          _totalsSection(),
          _divider(),
          _dateAndOriginalSection(),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              amountToWords(total, locale: 'en'),
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          _signatureBlock(),
          const SizedBox(height: AppSpacing.section),
          Wrap(spacing: AppSpacing.field, runSpacing: AppSpacing.field, alignment: WrapAlignment.center, children: actions),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 17, thickness: 1, color: AppColors.textPrimary);

  /// Short No./Date fields render right-aligned (label left, value right,
  /// same line) — matching the physical receipt's 50/50 two-column rows.
  /// Name fields print as their own two-line block (label, then value on
  /// the next line) and Pan fields glue the value straight onto the label
  /// with no space — both matching the receipt's colspan="2" rows exactly.
  /// The first Name/Pan/Payment/Ref field triggers the divider that
  /// separates the two groups on the real receipt.
  List<Widget> _metaFieldWidgets() {
    const style = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
    const normal = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
    final widgets = <Widget>[];
    var printedGroupDivider = false;

    for (final row in metaRows) {
      for (final field in row) {
        if (field == null) continue;
        final (label, value) = field;
        final isFullWidthField = label.contains('Name') || label.contains('Pan') || label.contains('Payment');
        if (isFullWidthField && !printedGroupDivider) {
          widgets.add(_divider());
          printedGroupDivider = true;
        }
        if (label.contains('Name')) {
          widgets.add(Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: Text('$label :', style: style)));
          widgets.add(Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: Text(value, style: normal)));
        } else if (label.contains('Pan')) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text.rich(TextSpan(style: style, children: [TextSpan(text: '$label :'), TextSpan(text: value, style: normal)])),
          ));
        } else if (isFullWidthField) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text.rich(TextSpan(style: style, children: [TextSpan(text: '$label : '), TextSpan(text: value, style: normal)])),
          ));
        } else {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(children: [
              Expanded(child: Text('$label :', style: style)),
              Text(value, style: normal),
            ]),
          ));
        }
      }
    }
    return widgets;
  }

  Widget _itemsTable() {
    // No TableBorder here — the surrounding `_divider()` calls in build()
    // already draw the line above/below the table; adding the table's own
    // top/bottom border on top of those doubled up the rule.
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.0),
        1: FlexColumnWidth(2.6),
        2: FlexColumnWidth(1.0),
        3: FlexColumnWidth(1.7),
        4: FlexColumnWidth(1.7),
      },
      children: [
        TableRow(children: [
          _headerCell('Sn', align: TextAlign.center),
          _headerCell('Description'),
          _headerCell('Qty', align: TextAlign.right),
          _headerCell('Rate', align: TextAlign.right),
          _headerCell('Amount', align: TextAlign.right),
        ]),
        for (var i = 0; i < items.length; i++)
          TableRow(children: [
            _InvoiceCell('${i + 1}', align: TextAlign.center),
            _InvoiceCell(items[i].description),
            _InvoiceCell(_qty(items[i].qty), align: TextAlign.right),
            _InvoiceCell(_money(items[i].rate), align: TextAlign.right),
            _InvoiceCell(_money(items[i].total), align: TextAlign.right),
          ]),
      ],
    );
  }

  // Always 2 decimals — matching the physical receipt's "1.00", not "1".
  static String _qty(double qty) => qty.toStringAsFixed(2);

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.textPrimary, width: 1)),
      ),
      child: _InvoiceCell(text, bold: true, align: align),
    );
  }

  Widget _totalsSection() {
    return Column(
      children: [
        _summaryRow('Taxable :', taxable),
        _summaryRow('Non Taxable :', nonTaxable),
        _summaryRow('Sub Total :', subtotal),
        _summaryRow('Discount 0.00% :', 0),
        _summaryRow(_vatLine(vatRateLabel), tax),
        if (delivery > 0) _summaryRow('Delivery Charge :', delivery),
        const Divider(height: 9, thickness: 1, color: AppColors.textPrimary),
        _summaryRow('Net Total :', total, bold: true),
      ],
    );
  }

  /// e.g. "13 %" (`vatRateLabel`) -> "VAT 13% :", matching the physical
  /// receipt's "VAT 13% :" line exactly (no "Amount", no parentheses).
  static String _vatLine(String vatRateLabel) {
    final rate = vatRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
    return 'VAT ${rate.isEmpty ? '13' : rate}% :';
  }

  /// e.g. 300000 -> "3,00,000.00" — the web receipt formats with
  /// `Intl.NumberFormat("en-IN")`, which groups the last 3 digits then
  /// pairs of 2 (lakh/crore style), not the western 3-3-3 grouping.
  static String _money(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final negative = fixed.startsWith('-');
    final unsigned = negative ? fixed.substring(1) : fixed;
    final dot = unsigned.indexOf('.');
    final whole = unsigned.substring(0, dot);
    final decimals = unsigned.substring(dot);

    String grouped;
    if (whole.length <= 3) {
      grouped = whole;
    } else {
      final last3 = whole.substring(whole.length - 3);
      var rest = whole.substring(0, whole.length - 3);
      final parts = <String>[];
      while (rest.length > 2) {
        parts.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.insert(0, rest);
      grouped = '${parts.join(',')},$last3';
    }
    return '${negative ? '-' : ''}$grouped$decimals';
  }

  Widget _dateAndOriginalSection() {
    final nepaliDate = nepaliDateLabel(printedAt);
    return Column(
      children: [
        Align(alignment: Alignment.centerLeft, child: _plainRow('Print Date/Time :', printDateTimeLabel(printedAt))),
        if (nepaliDate.isNotEmpty) Align(alignment: Alignment.centerLeft, child: _plainRow('Nepali Date :', nepaliDate)),
        const Text('Original', style: TextStyle(fontSize: 12)),
      ],
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
          Text(_money(value), style: style),
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

/// Shared dialog chrome — a sharp-cornered white card on a dark scrim,
/// matching the web modal's flat bordered card exactly (no rounded corners
/// or elevation shadow, which `Dialog`'s Material default would otherwise add).
Future<void> showTaxInvoiceDialog(BuildContext context, {required Widget document}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.overlayScrim,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 700),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.textPrimary)),
          padding: const EdgeInsets.all(AppSpacing.card),
          child: SingleChildScrollView(child: document),
        ),
      ),
    ),
  );
}
