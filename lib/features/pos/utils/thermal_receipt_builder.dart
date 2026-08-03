import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../widgets/invoice_document.dart';
import 'invoice_format_utils.dart';

class ThermalReceiptData {
  final String companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyVatNo;
  final String title;
  final String copyLabel;
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

  /// ESC/POS can't render a rotated watermark like the PDF/screen copies,
  /// so a cancelled bill instead gets a bold "CANCELLED" banner line.
  final bool isCancelled;

  const ThermalReceiptData({
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyVatNo,
    this.title = 'TAX INVOICE',
    this.copyLabel = '',
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
    this.isCancelled = false,
  });
}
List<int> buildThermalReceiptBytes(
  Generator generator,
  ThermalReceiptData data, {
  required int charsPerLine,
  bool cutAfter = true,
}) {
  const companyStyle = PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2);
  const titleStyle = PosStyles(align: PosAlign.center, bold: true);
  const center = PosStyles(align: PosAlign.center);
  const bold = PosStyles(bold: true);

  var bytes = generator.reset();

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

  bytes += generator.text(data.companyName, styles: companyStyle);
  if ((data.companyAddress ?? '').isNotEmpty) bytes += generator.text(data.companyAddress!, styles: center);
  bytes += generator.text('VAT # : ${data.companyVatNo ?? ''}', styles: center);
  if (data.title.isNotEmpty) bytes += generator.text(data.title, styles: titleStyle);
  if (data.copyLabel.isNotEmpty) bytes += generator.text(data.copyLabel, styles: const PosStyles(align: PosAlign.center, bold: true));
  bytes += generator.hr(len: charsPerLine);
  if (data.isCancelled) {
    bytes += generator.text(
      '*** CANCELLED ***',
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    );
    bytes += generator.hr(len: charsPerLine);
  }

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
  bytes += generator.hr(len: charsPerLine);
  if (data.preparedBy.isNotEmpty) bytes += lr(data.preparedBy, '');
  bytes += lr('-' * 12, '-' * 12);
  bytes += lr('Prepare By', data.signatureRightLabel, styles: bold);
  bytes += generator.hr(len: charsPerLine);
  if (cutAfter) {
    bytes += generator.feed(3);
    bytes += generator.cut();
  } else {
    bytes += generator.feed(6);
  }
  return bytes;
}

String _vatLine(String vatRateLabel) {
  final rate = vatRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
  return 'VAT ${rate.isEmpty ? '13' : rate}% :';
}

String _qty(double qty) => qty.round().toString();

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

class _ItemColumns {
  static const _gap = ' ';
  static const _gapCount = 5;

  final int sn;
  final int hsCode;
  final int description;
  final int qty;
  final int rate;
  final int amount;

  _ItemColumns(int charsPerLine)
      : sn = 2,
        hsCode = charsPerLine >= 40 ? 7 : 3,
        qty = charsPerLine >= 40 ? 3 : 2,
        rate = charsPerLine >= 40 ? 8 : 6,
        amount = charsPerLine >= 40 ? 8 : 6,
        description = (charsPerLine - _gapCount) -
            2 -
            (charsPerLine >= 40 ? 7 : 3) -
            (charsPerLine >= 40 ? 3 : 2) -
            (charsPerLine >= 40 ? 8 : 6) -
            (charsPerLine >= 40 ? 8 : 6);

  String _left(String s, int width) => s.length >= width ? s.substring(0, width) : s.padRight(width);
  String _right(String s, int width) => s.length >= width ? s.substring(0, width) : s.padLeft(width);

  String header() => [
        _left('Sn', sn),
        _left('HS Code', hsCode),
        _left('Description', description),
        _right('Qty', qty),
        _right('Rate', rate),
        _right('Amount', amount),
      ].join(_gap);

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
        out.add([
          _left(snValue, sn),
          _left(hsCodeValue, hsCode),
          _left(lines[i], description),
          _right(qtyValue, qty),
          _right(rateValue, rate),
          _right(amountValue, amount),
        ].join(_gap));
      } else {
        out.add([_left('', sn), _left('', hsCode), _left(lines[i], description)].join(_gap));
      }
    }
    return out;
  }
}
