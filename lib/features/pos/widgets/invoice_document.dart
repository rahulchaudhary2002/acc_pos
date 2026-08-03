import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../utils/invoice_format_utils.dart';

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

typedef MetaField = (String label, String value)?;

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
  final String copyLabel;

  final bool isCancelled;

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
    this.copyLabel = '',
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Arial', color: AppColors.textPrimary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Text(companyName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if ((companyAddress ?? '').isNotEmpty)
                Text(companyAddress!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              Text('VAT # : ${companyVatNo ?? ''}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: AppSpacing.field),
          if (title.isNotEmpty)
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (copyLabel.isNotEmpty)
            Text(copyLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          _divider(),
          ..._metaFieldWidgets(),
          _divider(),
          _itemsTable(),
          _divider(),
          _totalsSection(),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              amountToWords(total, locale: 'en'),
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
          _divider(),
          _dateAndOriginalSection(),
          _divider(),
          _signatureBlock(),
          _divider(),
          const SizedBox(height: AppSpacing.field),
          Wrap(spacing: AppSpacing.field, runSpacing: AppSpacing.field, alignment: WrapAlignment.center, children: actions),
        ],
      ),
    );

    if (!isCancelled) return content;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          child: Transform.rotate(
            angle: -0.5,
            child: Text(
              'CANCELLED',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.danger.withValues(alpha: 0.35),
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _divider() => const Divider(height: 17, thickness: 1, color: AppColors.textPrimary);

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
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.8),
        1: FlexColumnWidth(1.4),
        2: FlexColumnWidth(2.2),
        3: FlexColumnWidth(1.0),
        4: FlexColumnWidth(1.6),
        5: FlexColumnWidth(1.6),
      },
      children: [
        TableRow(children: [
          _headerCell('Sn', align: TextAlign.center),
          _headerCell('H.S. Code'),
          _headerCell('Description'),
          _headerCell('Qty', align: TextAlign.right),
          _headerCell('Rate', align: TextAlign.right),
          _headerCell('Amount', align: TextAlign.right),
        ]),
        for (var i = 0; i < items.length; i++)
          TableRow(children: [
            _InvoiceCell('${i + 1}', align: TextAlign.center),
            _InvoiceCell(items[i].hsCode),
            _InvoiceCell(items[i].description),
            _InvoiceCell(_qty(items[i].qty), align: TextAlign.right),
            _InvoiceCell(_money(items[i].rate), align: TextAlign.right),
            _InvoiceCell(_money(items[i].total), align: TextAlign.right),
          ]),
      ],
    );
  }

  static String _qty(double qty) => qty.round().toString();

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

  static String _vatLine(String vatRateLabel) {
    final rate = vatRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
    return 'VAT ${rate.isEmpty ? '13' : rate}% :';
  }

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
        Expanded(child: _signatureColumn(preparedBy.isEmpty ? 'Prepared By' : preparedBy, 'Prepared By')),
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
