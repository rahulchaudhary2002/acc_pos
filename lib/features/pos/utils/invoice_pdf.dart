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
  required double total,
  required String preparedBy,
  required String signatureRightLabel,
  required PosInvoiceLabels labels,
  String title = 'TAX INVOICE',
  String amountInWordsLocale = 'en',
}) async {
  final doc = pw.Document();
  final border = PdfColors.grey900;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(20),
      build: (context) => [
        pw.Center(
          child: pw.Column(children: [
            pw.Text(companyName.toUpperCase(), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            if ((companyAddress ?? '').isNotEmpty) pw.Text(companyAddress!, style: const pw.TextStyle(fontSize: 9)),
            if ((companyPhone ?? '').isNotEmpty) pw.Text('Phone No : $companyPhone', style: const pw.TextStyle(fontSize: 9)),
            if ((companyVatNo ?? '').isNotEmpty) pw.Text('VAT # : $companyVatNo', style: const pw.TextStyle(fontSize: 9)),
          ]),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
          ),
        ),
        pw.SizedBox(height: 10),
        for (final row in metaRows) _metaRow(row),
        pw.SizedBox(height: 10),
        _itemsTable(items, border),
        pw.SizedBox(height: 10),
        _totalsSection(printedAt, taxable, nonTaxable, subtotal, vatRateLabel, tax, total, border),
        pw.SizedBox(height: 6),
        pw.Text(amountToWords(total), style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 24),
        pw.Row(children: [
          pw.Expanded(child: _signatureColumn(preparedBy.isEmpty ? 'Prepared By' : preparedBy, 'Prepare By')),
          pw.SizedBox(width: 24),
          pw.Expanded(child: _signatureColumn('', signatureRightLabel)),
        ]),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _metaRow(List<MetaField> row) {
  if (row.every((f) => f == null)) return pw.SizedBox();
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(children: [
      pw.Expanded(child: row.isNotEmpty && row[0] != null ? _metaField(row[0]!) : pw.SizedBox()),
      pw.SizedBox(width: 8),
      pw.Expanded(child: row.length > 1 && row[1] != null ? _metaField(row[1]!) : pw.SizedBox()),
    ]),
  );
}

pw.Widget _metaField((String, String) field) {
  final (label, value) = field;
  return pw.RichText(
    text: pw.TextSpan(
      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      children: [
        pw.TextSpan(text: '$label : '),
        pw.TextSpan(text: value, style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
      ],
    ),
  );
}

pw.Widget _itemsTable(List<InvoiceLineData> items, PdfColor border) {
  String qty(double q) => q.toStringAsFixed(q.truncateToDouble() == q ? 0 : 2);
  return pw.Table(
    border: pw.TableBorder(
      top: pw.BorderSide(color: border, width: 1),
      bottom: pw.BorderSide(color: border, width: 1),
      horizontalInside: pw.BorderSide(color: border, width: 0.5),
    ),
    columnWidths: const {
      0: pw.FlexColumnWidth(0.6),
      1: pw.FlexColumnWidth(1.3),
      2: pw.FlexColumnWidth(3),
      3: pw.FlexColumnWidth(1),
      4: pw.FlexColumnWidth(1.2),
      5: pw.FlexColumnWidth(1.3),
    },
    children: [
      pw.TableRow(children: [
        _cell('Sr.', bold: true, align: pw.TextAlign.center),
        _cell('H.S. Code', bold: true),
        _cell('Description', bold: true),
        _cell('Qty.', bold: true, align: pw.TextAlign.right),
        _cell('Rate', bold: true, align: pw.TextAlign.right),
        _cell('Total Amt.', bold: true, align: pw.TextAlign.right),
      ]),
      for (var i = 0; i < items.length; i++)
        pw.TableRow(children: [
          _cell('${i + 1}', align: pw.TextAlign.center),
          _cell(items[i].hsCode.isEmpty ? '-' : items[i].hsCode),
          _cell(items[i].description),
          _cell(qty(items[i].qty), align: pw.TextAlign.right),
          _cell(items[i].rate.toStringAsFixed(2), align: pw.TextAlign.right),
          _cell(items[i].total.toStringAsFixed(2), align: pw.TextAlign.right),
        ]),
    ],
  );
}

pw.Widget _cell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
    child: pw.Text(text, textAlign: align, style: pw.TextStyle(fontSize: 8, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );
}

pw.Widget _totalsSection(
  DateTime printedAt,
  double taxable,
  double nonTaxable,
  double subtotal,
  String vatRateLabel,
  double tax,
  double total,
  PdfColor border,
) {
  pw.Widget summaryRow(String label, double value, {bool bold = false}) {
    final style = pw.TextStyle(fontSize: bold ? 10 : 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(children: [
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Text(value.toStringAsFixed(2), style: style),
      ]),
    );
  }

  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: border, width: 1))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Print Date/Time : ${printDateTimeLabel(printedAt)}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Nepali Date : ${nepaliDateLabel(printedAt)}', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 6),
            pw.Text('Original', style: const pw.TextStyle(fontSize: 9)),
          ]),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          flex: 4,
          child: pw.Column(children: [
            summaryRow('Taxable :', taxable),
            summaryRow('Non Taxable :', nonTaxable),
            summaryRow('Sub Total :', subtotal),
            summaryRow('Discount : 0 %', 0),
            summaryRow(vatRateLabel.isEmpty ? 'VAT Amount :' : 'VAT Amount ($vatRateLabel) :', tax),
            summaryRow('Net Total :', total, bold: true),
          ]),
        ),
      ],
    ),
  );
}

pw.Widget _signatureColumn(String name, String label) {
  return pw.Column(children: [
    pw.SizedBox(height: 14, child: pw.Text(name, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
    pw.Text('--------------------', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
    pw.SizedBox(height: 3),
    pw.Text(label, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
  ]);
}
