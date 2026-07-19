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
  final double delivery;
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
    this.delivery = 0,
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
  // Company name is the only double-size line — the title and everything
  // else print at normal size, matching the actual printed receipt (the
  // title is bold but NOT double-height like the company name).
  const companyStyle = PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2);
  const titleStyle = PosStyles(align: PosAlign.center, bold: true);
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

  // Company name is printed exactly as stored (no forced upper-casing) —
  // matches the physical receipt showing "Head Office", not "HEAD OFFICE".
  bytes += generator.text(data.companyName, styles: companyStyle);
  if ((data.companyAddress ?? '').isNotEmpty) bytes += generator.text(data.companyAddress!, styles: center);
  bytes += generator.text('VAT # : ${data.companyVatNo ?? ''}', styles: center);
  bytes += generator.text(data.title, styles: titleStyle);
  bytes += generator.hr(len: charsPerLine);

  // Short No./Date fields render right-aligned (label left, value right,
  // same line) — matching the web receipt's 50/50 two-column table. Name
  // fields print as their own two-line block (label, then value on the next
  // line) and Pan fields glue the value straight onto the label with no
  // space — both matching the web receipt's colspan="2" rows exactly. The
  // first Name/Pan-style field triggers the divider that separates the two
  // groups on the real receipt.
  var printedGroupDivider = false;
  for (final row in data.metaRows) {
    for (final field in row) {
      if (field == null) continue;
      final (label, value) = field;
      final isFullWidthField = label.contains('Name') || label.contains('Pan') || label.contains('Payment');
      if (isFullWidthField && !printedGroupDivider) {
        bytes += generator.hr(len: charsPerLine);
        printedGroupDivider = true;
      }
      if (label.contains('Name')) {
        bytes += generator.text('$label :', styles: bold, maxCharsPerLine: charsPerLine);
        bytes += generator.text(value, maxCharsPerLine: charsPerLine);
      } else if (label.contains('Pan')) {
        bytes += generator.text('$label :$value', styles: bold, maxCharsPerLine: charsPerLine);
      } else if (isFullWidthField) {
        bytes += generator.text('$label : $value', styles: bold, maxCharsPerLine: charsPerLine);
      } else {
        bytes += lr('$label :', value, styles: bold);
      }
    }
  }

  // Sn/H.S. Code/Description/Qty/Rate/Amount as real fixed-width columns,
  // wrapping the description onto extra lines under its own column when it's
  // too long for a single row — matching the receipt's "LPG 50 KG" then
  // "(Customer Price)" on the next line.
  final cols = _ItemColumns(charsPerLine);
  bytes += generator.hr(len: charsPerLine);
  bytes += generator.text(cols.header(), styles: bold, maxCharsPerLine: charsPerLine);
  bytes += generator.hr(len: charsPerLine);
  for (var i = 0; i < data.items.length; i++) {
    final item = data.items[i];
    for (final line in cols.itemLines('${i + 1}', item.hsCode, item.description, _qty(item.qty), _money(item.rate), _money(item.total))) {
      bytes += generator.text(line, maxCharsPerLine: charsPerLine);
    }
  }
  bytes += generator.hr(len: charsPerLine);

  bytes += lr('Taxable :', _money(data.taxable));
  bytes += lr('Non Taxable :', _money(data.nonTaxable));
  bytes += lr('Sub Total :', _money(data.subtotal));
  bytes += lr('Discount 0.00% :', _money(0));
  bytes += lr(_vatLine(data.vatRateLabel), _money(data.tax));
  if (data.delivery > 0) bytes += lr('Delivery Charge :', _money(data.delivery));
  bytes += generator.hr(len: charsPerLine);
  bytes += lr('Net Total :', _money(data.total), styles: const PosStyles(bold: true, height: PosTextSize.size2));
  bytes += generator.hr(len: charsPerLine);

  bytes += generator.text(amountToWords(data.total), maxCharsPerLine: charsPerLine);
  bytes += generator.hr(len: charsPerLine);

  bytes += generator.text('Print Date/Time : ${printDateTimeLabel(data.printedAt)}', maxCharsPerLine: charsPerLine);
  final nepaliDate = nepaliDateLabel(data.printedAt);
  if (nepaliDate.isNotEmpty) bytes += generator.text('Nepali Date : $nepaliDate', maxCharsPerLine: charsPerLine);
  bytes += generator.text('Original', styles: center, maxCharsPerLine: charsPerLine);
  bytes += generator.hr(len: charsPerLine);
  if (data.preparedBy.isNotEmpty) bytes += lr(data.preparedBy, '');
  bytes += lr('-' * 12, '-' * 12);
  bytes += lr('Prepare By', data.signatureRightLabel, styles: bold);
  bytes += generator.hr(len: charsPerLine);
  bytes += generator.feed(3);
  bytes += generator.cut();
  return bytes;
}

/// e.g. "13 %" (web's `vatRateLabel`) -> "VAT 13% :", matching the physical
/// receipt's "VAT 13% :" line exactly (no "Amount", no parentheses).
String _vatLine(String vatRateLabel) {
  final rate = vatRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
  return 'VAT ${rate.isEmpty ? '13' : rate}% :';
}

String _qty(double qty) => qty.round().toString();

/// e.g. 300000 -> "3,00,000.00" — the web receipt formats with
/// `Intl.NumberFormat("en-IN")`, which groups the last 3 digits then pairs
/// of 2 (lakh/crore style), not the western 3-3-3 grouping.
String _money(double amount) {
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

/// Fixed-width Sn/H.S. Code/Description/Qty/Rate/Amount columns for the item
/// table, proportioned like invoice_pdf.dart's FlexColumnWidth ratios
/// (0.6 : 1.0 : 2.2 : 1.0 : 1.7 : 1.7) so the thermal ticket's table lines up
/// the same way the PDF/on-screen table does — Rate/Amount get extra room so
/// comma-grouped amounts (e.g. "3,00,000.00") don't get truncated.
class _ItemColumns {
  final int sn;
  final int hsCode;
  final int description;
  final int qty;
  final int rate;
  final int amount;

  _ItemColumns(int charsPerLine)
      : sn = (charsPerLine * 0.6 / 8.2).round(),
        hsCode = (charsPerLine * 1.0 / 8.2).round(),
        qty = (charsPerLine * 1.0 / 8.2).round(),
        rate = (charsPerLine * 1.7 / 8.2).round(),
        amount = charsPerLine -
            (charsPerLine * 0.6 / 8.2).round() -
            (charsPerLine * 1.0 / 8.2).round() -
            (charsPerLine * 2.2 / 8.2).round() -
            (charsPerLine * 1.0 / 8.2).round() -
            (charsPerLine * 1.7 / 8.2).round(),
        description = (charsPerLine * 2.2 / 8.2).round();

  String _left(String s, int width) => s.length >= width ? s.substring(0, width) : s.padRight(width);
  String _right(String s, int width) => s.length >= width ? s.substring(0, width) : s.padLeft(width);

  String header() =>
      _left('Sn', sn) + _left('HS', hsCode) + _left('Description', description) + _right('Qty', qty) + _right('Rate', rate) + _right('Amount', amount);

  /// First line carries Sn/H.S. Code/Qty/Rate/Amount; the description wraps
  /// onto blank-column continuation lines when it doesn't fit (e.g.
  /// "LPG 50 KG" then "(Customer Price)" on its own line, indented under
  /// Description).
  List<String> itemLines(
    String snValue,
    String hsCodeValue,
    String descriptionValue,
    String qtyValue,
    String rateValue,
    String amountValue,
  ) {
    final words = descriptionValue.split(' ');
    final lines = <String>[];
    var current = '';
    for (final word in words) {
      final candidate = current.isEmpty ? word : '$current $word';
      if (candidate.length > description && current.isNotEmpty) {
        lines.add(current);
        current = word;
      } else {
        current = candidate;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    if (lines.isEmpty) lines.add('');

    final out = <String>[];
    for (var i = 0; i < lines.length; i++) {
      if (i == 0) {
        out.add(_left(snValue, sn) +
            _left(hsCodeValue, hsCode) +
            _left(lines[i], description) +
            _right(qtyValue, qty) +
            _right(rateValue, rate) +
            _right(amountValue, amount));
      } else {
        out.add(_left('', sn) + _left('', hsCode) + _left(lines[i], description));
      }
    }
    return out;
  }
}
