import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../widgets/invoice_document.dart';
import 'invoice_format_utils.dart';

/// Everything the thermal receipt needs — the same data the A5 preview/Share
/// PDF is built from (see `invoice_pdf.dart`), just laid out for a narrow
/// roll instead of a full page.
class ThermalReceiptData {
  final String companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyVatNo;
  final String title;
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

  const ThermalReceiptData({
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyVatNo,
    this.title = 'TAX INVOICE',
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
  });
}

/// Builds an ESC/POS ticket for [data], mirroring the on-screen bill's
/// structure: company header, title, meta lines, items, right-aligned
/// totals, amount-in-words, dates, and the signature labels.
///
/// [charsPerLine] is the printer's character width (32 on 58mm paper, 48 on
/// 80mm). Every two-sided line is composed by manual space-padding to that
/// width instead of `Generator.row()` — `row()` positions columns with the
/// ESC `$` absolute-position command, which many budget Bluetooth printers
/// ignore or misplace, leaving dividers stopping mid-paper and totals
/// printed at the wrong offset. Plain padded text lines render correctly on
/// everything. Only the company name and title use double-size styling;
/// numbers stay at normal size like the preview.
List<int> buildThermalReceiptBytes(Generator generator, ThermalReceiptData data, {required int charsPerLine}) {
  const big = PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2);
  const center = PosStyles(align: PosAlign.center);
  const bold = PosStyles(bold: true);

  var bytes = generator.reset();

  // Two-sided line: left text, right text pushed to the paper edge. Wraps the
  // right side onto its own right-aligned line when both don't fit.
  List<int> lr(String left, String right, {PosStyles styles = const PosStyles()}) {
    var out = <int>[];
    if (left.length + right.length + 1 > charsPerLine) {
      out += generator.text(left, styles: styles, maxCharsPerLine: charsPerLine);
      out += generator.text(right.padLeft(charsPerLine), styles: styles, maxCharsPerLine: charsPerLine);
    } else {
      out += generator.text(left + right.padLeft(charsPerLine - left.length), styles: styles, maxCharsPerLine: charsPerLine);
    }
    return out;
  }

  bytes += generator.text(data.companyName.toUpperCase(), styles: big);
  if ((data.companyAddress ?? '').isNotEmpty) bytes += generator.text(data.companyAddress!, styles: center);
  if ((data.companyPhone ?? '').isNotEmpty) bytes += generator.text('Phone No : ${data.companyPhone}', styles: center);
  if ((data.companyVatNo ?? '').isNotEmpty) bytes += generator.text('VAT # : ${data.companyVatNo}', styles: center);
  bytes += generator.hr(ch: '=', len: charsPerLine);
  bytes += generator.text(data.title, styles: big);
  bytes += generator.hr(ch: '=', len: charsPerLine);

  for (final row in data.metaRows) {
    for (final field in row) {
      if (field == null) continue;
      final (label, value) = field;
      bytes += generator.text('$label : $value', maxCharsPerLine: charsPerLine);
    }
  }

  bytes += generator.hr(len: charsPerLine);
  bytes += lr('Description  Qty x Rate', 'Amount', styles: bold);
  bytes += generator.hr(len: charsPerLine);
  for (var i = 0; i < data.items.length; i++) {
    final item = data.items[i];
    bytes += generator.text('${i + 1}. ${item.description}', styles: bold, maxCharsPerLine: charsPerLine);
    bytes += lr('   ${_qty(item.qty)} x ${item.rate.toStringAsFixed(2)}', item.total.toStringAsFixed(2));
  }
  bytes += generator.hr(len: charsPerLine);

  bytes += lr('Taxable :', data.taxable.toStringAsFixed(2));
  bytes += lr('Non Taxable :', data.nonTaxable.toStringAsFixed(2));
  bytes += lr('Sub Total :', data.subtotal.toStringAsFixed(2));
  bytes += lr('Discount : 0 %', (0.0).toStringAsFixed(2));
  bytes += lr(data.vatRateLabel.isEmpty ? 'VAT Amount :' : 'VAT Amount (${data.vatRateLabel}) :', data.tax.toStringAsFixed(2));
  bytes += generator.hr(len: charsPerLine);
  bytes += lr('Net Total :', data.total.toStringAsFixed(2), styles: bold);
  bytes += generator.hr(ch: '=', len: charsPerLine);

  bytes += generator.text(amountToWords(data.total), maxCharsPerLine: charsPerLine);
  bytes += generator.feed(1);
  bytes += generator.text('Print Date/Time : ${printDateTimeLabel(data.printedAt)}', maxCharsPerLine: charsPerLine);
  final nepaliDate = nepaliDateLabel(data.printedAt);
  if (nepaliDate.isNotEmpty) bytes += generator.text('Nepali Date : $nepaliDate', maxCharsPerLine: charsPerLine);
  bytes += generator.text('Original', maxCharsPerLine: charsPerLine);

  bytes += generator.feed(2);
  if (data.preparedBy.isNotEmpty) bytes += lr(data.preparedBy, '');
  bytes += lr('-' * 12, '-' * 12);
  bytes += lr('Prepare By', data.signatureRightLabel);
  bytes += generator.feed(3);
  bytes += generator.cut();
  return bytes;
}

String _qty(double qty) => qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2);
