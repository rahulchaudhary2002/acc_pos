import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../widgets/invoice_document.dart';
import 'invoice_format_utils.dart';

/// Localized labels for the printed invoice. This file is a pure Dart
/// function with no `BuildContext`, so it can't call `AppLocalizations`
/// itself — callers (which do have a `BuildContext`, e.g.
/// `invoice_preview_dialog.dart`) resolve these via
/// `AppLocalizations.of(context)!` and pass them in.
class PosInvoiceLabels {
  final String Function(String phone) phone;
  final String Function(String vatNo) vat;
  final String srHeader;
  final String hsCodeHeader;
  final String descriptionHeader;
  final String qtyHeader;
  final String rateHeader;
  final String totalAmtHeader;
  final String printDateTime;
  final String nepaliDate;
  final String original;
  final String taxable;
  final String nonTaxable;
  final String subTotal;
  final String discount;
  final String vatAmount;
  final String Function(String rate) vatAmountWithRate;
  final String netTotal;
  final String preparedByFallback;
  final String prepareBy;

  const PosInvoiceLabels({
    required this.phone,
    required this.vat,
    required this.srHeader,
    required this.hsCodeHeader,
    required this.descriptionHeader,
    required this.qtyHeader,
    required this.rateHeader,
    required this.totalAmtHeader,
    required this.printDateTime,
    required this.nepaliDate,
    required this.original,
    required this.taxable,
    required this.nonTaxable,
    required this.subTotal,
    required this.discount,
    required this.vatAmount,
    required this.vatAmountWithRate,
    required this.netTotal,
    required this.preparedByFallback,
    required this.prepareBy,
  });
}

/// Builds an A5 PDF of the tax invoice for the Print/Share actions —
/// mirrors the on-screen `TaxInvoiceDocument` layout (and the web app's
/// jsPDF-generated receipt) so what gets printed/shared matches what the
/// user just saw.
Future<Uint8List> buildInvoicePdfBytes({
  required String companyName,
  String? companyAddress,
  String? companyPhone,
  String? companyVatNo,
  required List<List<MetaField>> metaRows,
  required List<InvoiceLineData> items,
  required DateTime printedAt,
  required double taxable,
  required double nonTaxable,
  required double subtotal,
  required String vatRateLabel,
  required double tax,
  double delivery = 0,
  required double total,
  required String preparedBy,
  required String signatureRightLabel,
  required PosInvoiceLabels labels,
  String title = 'TAX INVOICE',
  String copyLabel = 'Original',
  String amountInWordsLocale = 'en',
  bool isCancelled = false,
}) async {
  final doc = pw.Document();
  doc.addPage(_invoicePage(
    companyName: companyName,
    companyAddress: companyAddress,
    companyVatNo: companyVatNo,
    metaRows: metaRows,
    items: items,
    printedAt: printedAt,
    taxable: taxable,
    nonTaxable: nonTaxable,
    subtotal: subtotal,
    vatRateLabel: vatRateLabel,
    tax: tax,
    delivery: delivery,
    total: total,
    preparedBy: preparedBy,
    signatureRightLabel: signatureRightLabel,
    title: title,
    copyLabel: copyLabel,
    isCancelled: isCancelled,
  ));

  return doc.save();
}

/// A sales invoice always prints both the tax invoice and the plain invoice
/// copy together, as a single print/share action — [copies] is
/// `[('TAX INVOICE', copyLabel), ('INVOICE', copyLabel)]`, each rendered as
/// its own page in one PDF so a single Print/Share hands over both at once.
Future<Uint8List> buildInvoicePdfBytesForCopies({
  required String companyName,
  String? companyAddress,
  String? companyPhone,
  String? companyVatNo,
  required List<List<MetaField>> metaRows,
  required List<InvoiceLineData> items,
  required DateTime printedAt,
  required double taxable,
  required double nonTaxable,
  required double subtotal,
  required String vatRateLabel,
  required double tax,
  double delivery = 0,
  required double total,
  required String preparedBy,
  required String signatureRightLabel,
  required PosInvoiceLabels labels,
  required List<(String title, String copyLabel)> copies,
  bool isCancelled = false,
}) async {
  final doc = pw.Document();
  for (final (title, copyLabel) in copies) {
    doc.addPage(_invoicePage(
      companyName: companyName,
      companyAddress: companyAddress,
      companyVatNo: companyVatNo,
      metaRows: metaRows,
      items: items,
      printedAt: printedAt,
      taxable: taxable,
      nonTaxable: nonTaxable,
      subtotal: subtotal,
      vatRateLabel: vatRateLabel,
      tax: tax,
      delivery: delivery,
      total: total,
      preparedBy: preparedBy,
      signatureRightLabel: signatureRightLabel,
      title: title,
      copyLabel: copyLabel,
      isCancelled: isCancelled,
    ));
  }

  return doc.save();
}

pw.MultiPage _invoicePage({
  required String companyName,
  String? companyAddress,
  String? companyVatNo,
  required List<List<MetaField>> metaRows,
  required List<InvoiceLineData> items,
  required DateTime printedAt,
  required double taxable,
  required double nonTaxable,
  required double subtotal,
  required String vatRateLabel,
  required double tax,
  required double delivery,
  required double total,
  required String preparedBy,
  required String signatureRightLabel,
  required String title,
  required String copyLabel,
  bool isCancelled = false,
}) {
  final border = PdfColors.grey900;
  // 80mm x 297mm thermal roll — matches the physical thermal printer this
  // actually prints on (not an A5 sheet printer), and the same
  // "80mm 297mm" @page size the web app's browser print CSS already uses
  // for this printer.
  final pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, 297 * PdfPageFormat.mm);

  final contentWidgets = <pw.Widget>[
    pw.Center(
      child: pw.Column(children: [
        // Printed exactly as stored — no forced upper-casing — matching
        // the physical receipt showing "Head Office", not "HEAD OFFICE".
        pw.Text(companyName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        if ((companyAddress ?? '').isNotEmpty) pw.Text(companyAddress!, style: const pw.TextStyle(fontSize: 9)),
        pw.Text('VAT # : ${companyVatNo ?? ''}', style: const pw.TextStyle(fontSize: 9)),
      ]),
    ),
    pw.SizedBox(height: 4),
    pw.Center(
      child: pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
    ),
    pw.Center(
      child: pw.Text(copyLabel, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    ),
    pw.Divider(color: border, thickness: 1, height: 9),
    ..._metaFieldWidgets(metaRows, border),
    pw.Divider(color: border, thickness: 1, height: 9),
    _itemsTable(items, border),
    pw.Divider(color: border, thickness: 1, height: 9),
    _totalsSection(taxable, nonTaxable, subtotal, vatRateLabel, tax, delivery, total),
    pw.Divider(color: border, thickness: 1, height: 9),
    pw.Text(amountToWords(total), style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
    pw.Divider(color: border, thickness: 1, height: 9),
    _dateAndOriginalSection(printedAt),
    pw.Divider(color: border, thickness: 1, height: 9),
    pw.SizedBox(height: 8),
    pw.Row(children: [
      pw.Expanded(child: _signatureColumn(preparedBy.isEmpty ? 'Prepared By' : preparedBy, 'Prepared By')),
      pw.SizedBox(width: 24),
      pw.Expanded(child: _signatureColumn('', signatureRightLabel)),
    ]),
    pw.Divider(color: border, thickness: 1, height: 9),
  ];

  return pw.MultiPage(
    pageFormat: pageFormat,
    margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    // Cancelled receipts wrap all content in one Stack instead of returning
    // the flat widget list directly — a `pageTheme.buildBackground` paints
    // across the full 297mm page regardless of how short the content is,
    // which left "CANCELLED" floating in the blank space below a short
    // receipt instead of over it. A Stack sizes to its content (the Column
    // here), so the centered, rotated overlay lands within the actual
    // printed area. Trade-off: this content must fit on one page — fine for
    // these short thermal receipts, but it forgoes automatic pagination.
    build: (context) => isCancelled
        ? [
            pw.Stack(
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: contentWidgets),
                pw.Positioned.fill(
                  child: pw.Center(
                    // Positive here (unlike the -0.5 used for the on-screen
                    // preview's plain Center/Transform.rotate) — inside a
                    // Positioned.fill within a Stack, the pdf package's
                    // rotation direction comes out flipped, so this is what
                    // actually renders ascending bottom-left-to-top-right,
                    // matching the web receipt's watermark.
                    child: pw.Transform.rotate(
                      angle: 0.5,
                      child: pw.Text(
                        'CANCELLED',
                        style: pw.TextStyle(color: PdfColors.grey400, fontWeight: pw.FontWeight.bold, fontSize: 34),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]
        : contentWidgets,
  );
}

/// Short No./Date fields render right-aligned (label left, value right, same
/// line) — matching the physical receipt's 50/50 two-column rows. Name
/// fields print as their own two-line block (label, then value on the next
/// line) and Pan fields glue the value straight onto the label with no
/// space — both matching the receipt's colspan="2" rows exactly. The first
/// Name/Pan/Payment/Ref field triggers the divider that separates the two
/// groups on the real receipt.
List<pw.Widget> _metaFieldWidgets(List<List<MetaField>> metaRows, PdfColor border) {
  const style = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.normal);
  const normal = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.normal);
  final widgets = <pw.Widget>[];
  var printedGroupDivider = false;

  for (final row in metaRows) {
    for (final field in row) {
      if (field == null) continue;
      final (label, value) = field;
      final isFullWidthField = label.contains('Name') || label.contains('Pan') || label.contains('Payment');
      if (isFullWidthField && !printedGroupDivider) {
        widgets.add(pw.Divider(color: border, thickness: 1, height: 9));
        printedGroupDivider = true;
      }
      if (label.contains('Name')) {
        widgets.add(pw.Text('$label :', style: style));
        widgets.add(pw.Text(value, style: normal));
      } else if (label.contains('Pan')) {
        widgets.add(pw.RichText(text: pw.TextSpan(style: style, children: [pw.TextSpan(text: '$label :'), pw.TextSpan(text: value, style: normal)])));
      } else if (isFullWidthField) {
        widgets.add(pw.RichText(text: pw.TextSpan(style: style, children: [pw.TextSpan(text: '$label : '), pw.TextSpan(text: value, style: normal)])));
      } else {
        widgets.add(pw.Row(children: [
          pw.Expanded(child: pw.Text('$label :', style: style)),
          pw.Text(value, style: normal),
        ]));
      }
    }
  }
  return widgets;
}

pw.Widget _itemsTable(List<InvoiceLineData> items, PdfColor border) {
  String qty(double q) => q.round().toString();
  // No TableBorder here — the surrounding pw.Divider calls in
  // buildInvoicePdfBytes already draw the line above/below the table; a
  // table-level top/bottom border on top of those doubled up the rule.
  return pw.Table(
    columnWidths: const {
      0: pw.FlexColumnWidth(0.6),
      1: pw.FlexColumnWidth(1.2),
      2: pw.FlexColumnWidth(2.2),
      3: pw.FlexColumnWidth(0.8),
      4: pw.FlexColumnWidth(1.6),
      5: pw.FlexColumnWidth(1.6),
    },
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: border, width: 1))),
        children: [
          _cell('Sn', bold: true, align: pw.TextAlign.center),
          _cell('H.S. Code', bold: true),
          _cell('Description', bold: true),
          _cell('Qty', bold: true, align: pw.TextAlign.right),
          _cell('Rate', bold: true, align: pw.TextAlign.right),
          _cell('Amount', bold: true, align: pw.TextAlign.right),
        ],
      ),
      for (var i = 0; i < items.length; i++)
        pw.TableRow(children: [
          _cell('${i + 1}', align: pw.TextAlign.center),
          _cell(items[i].hsCode),
          _cell(items[i].description),
          _cell(qty(items[i].qty), align: pw.TextAlign.right),
          _cell(_money(items[i].rate), align: pw.TextAlign.right),
          _cell(_money(items[i].total), align: pw.TextAlign.right),
        ]),
    ],
  );
}

pw.Widget _cell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 1, vertical: 2),
    child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );
}

pw.Widget _totalsSection(
  double taxable,
  double nonTaxable,
  double subtotal,
  String vatRateLabel,
  double tax,
  double delivery,
  double total,
) {
  pw.Widget summaryRow(String label, double value, {bool bold = false}) {
    final style = pw.TextStyle(fontSize: bold ? 11 : 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(children: [
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Text(_money(value), style: style),
      ]),
    );
  }

  return pw.Column(children: [
    summaryRow('Taxable :', taxable),
    summaryRow('Non Taxable :', nonTaxable),
    summaryRow('Sub Total :', subtotal),
    summaryRow('Discount 0.00% :', 0),
    summaryRow(_vatLine(vatRateLabel), tax),
    if (delivery > 0) summaryRow('Delivery Charge :', delivery),
    pw.Divider(color: PdfColors.grey900, thickness: 1, height: 5),
    summaryRow('Net Total :', total, bold: true),
  ]);
}

pw.Widget _dateAndOriginalSection(DateTime printedAt) {
  final nepaliDate = nepaliDateLabel(printedAt);
  return pw.Column(children: [
    pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text('Print Date/Time : ${printDateTimeLabel(printedAt)}', style: const pw.TextStyle(fontSize: 9)),
    ),
    if (nepaliDate.isNotEmpty)
      pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('Nepali Date : $nepaliDate', style: const pw.TextStyle(fontSize: 9))),
  ]);
}

/// e.g. "13 %" (`vatRateLabel`) -> "VAT 13% :", matching the physical
/// receipt's "VAT 13% :" line exactly (no "Amount", no parentheses).
String _vatLine(String vatRateLabel) {
  final rate = vatRateLabel.replaceAll(RegExp(r'[^0-9.]'), '');
  return 'VAT ${rate.isEmpty ? '13' : rate}% :';
}

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

pw.Widget _signatureColumn(String name, String label) {
  return pw.Column(children: [
    pw.SizedBox(height: 12, child: pw.Text(name, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
    pw.Text('--------------', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9)),
    pw.SizedBox(height: 2),
    pw.Text(label, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
  ]);
}
