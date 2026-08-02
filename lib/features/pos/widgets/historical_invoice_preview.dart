import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/company.dart';
import '../models/json_utils.dart';
import '../models/outlet.dart';
import '../services/pos_service.dart';
import '../utils/invoice_format_utils.dart';
import '../utils/invoice_pdf.dart';
import '../utils/thermal_receipt_builder.dart';
import 'invoice_document.dart';
import 'printer_picker_sheet.dart';

/// Re-prints a previously posted sales invoice / purchase bill from its full
/// `GET /admin/{sales-invoices|purchase-bills}/{id}` JSON (as opposed to the
/// post-checkout preview dialogs, which build from live in-memory cart
/// state) — used by the Recent Bills screen's Print action. Reuses the same
/// `TaxInvoiceDocument`/`showTaxInvoiceDialog`/`ThermalReceiptData`/
/// `buildInvoicePdfBytes` pipeline so a re-printed bill looks identical to
/// the one shown right after checkout.
Future<void> showHistoricalSalesInvoicePreview(
  BuildContext context, {
  required Map<String, dynamic> invoice,
}) {
  final outletJson = invoice['outlet'] as Map<String, dynamic>?;
  final companyJson = outletJson?['company'] as Map<String, dynamic>?;
  final customerJson = invoice['customer'] as Map<String, dynamic>?;

  final company = companyJson != null
      ? Company.fromJson(companyJson)
      : Company(id: 0, name: 'LPG Vendor');
  final outlet = outletJson != null ? Outlet.fromJson(outletJson) : null;

  final lines = _linesFrom(invoice);
  final subtotal = asDoubleOrNull(invoice['subtotal']) ?? _sumLineSubtotal(lines);
  final tax = asDoubleOrNull(invoice['tax_total']) ?? 0;
  final delivery = asDoubleOrNull(invoice['delivery_charge']) ?? 0;
  final total = asDoubleOrNull(invoice['grand_total']) ?? (subtotal + tax + delivery);
  final printedOn = DateTime.now();
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';
  final taxSummary = computeTaxSummary(lines.map((l) => (l.taxRate, l.total)));

  final paymentMode = (invoice['payment_mode'] as String?) ?? '';
  final paymentReference = invoice['payment_reference'] as String?;
  final paymentNote = invoice['payment_note'] as String?;
  var customerPan = (customerJson?['pan_vat_no'] as String?) ?? '';
  if (customerPan == 'N/A' || customerPan == '-') customerPan = '';

  final metaRows = [
    [
      ('Invoice No', (invoice['invoice_no'] as String?) ?? '-'),
      ('Ref. No.', (invoice['reference_no'] as String?) ?? (invoice['invoice_no'] as String?) ?? '-'),
    ],
    [
      ('Invoice Date', _formatDate(invoice['invoice_date'] as String?)),
      ('Counter No.', counterNo),
    ],
    [
      ('Customer Name', (customerJson?['name'] as String?) ?? 'Walk-in Customer'),
      ('Payment Mode', paymentMode.replaceAll('_', ' ')),
    ],
    [('Customer Pan', customerPan), null],
    if ((paymentReference ?? '').isNotEmpty || (paymentNote ?? '').isNotEmpty)
      [
        (paymentReference ?? '').isNotEmpty ? ('Payment Ref.', paymentReference!) : null,
        (paymentNote ?? '').isNotEmpty ? ('Payment Note', paymentNote!) : null,
      ],
  ];

  final documentNo = (invoice['invoice_no'] as String?) ?? '-';
  final invoiceId = asIntOrNull(invoice['id']);
  final printCount = asIntOrNull(invoice['print_count']) ?? 0;

  return _showHistoricalDialog(
    context,
    company: company,
    outlet: outlet,
    metaRows: metaRows,
    lines: lines,
    printedOn: printedOn,
    taxSummary: taxSummary,
    subtotal: subtotal,
    tax: tax,
    delivery: delivery,
    total: total,
    signatureRightLabel: 'Customer',
    pdfName: 'Invoice-$documentNo',
    title: null,
    // A sales invoice always prints both the tax invoice and the plain
    // invoice copy together, as a single print action.
    dualInvoiceCopies: true,
    recordPrintId: invoiceId,
    recordPrint: invoiceId == null ? null : (id) => context.read<PosService>().recordSalesInvoicePrint(id),
    initialPrintCount: printCount,
    preparedBy: (invoice['created_by'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    isCancelled: invoice['status'] == 'cancelled',
  );
}

/// Purchase-bill counterpart of [showHistoricalSalesInvoicePreview] —
/// vendor fields instead of customer, "Supplier" on the signature line.
Future<void> showHistoricalPurchaseBillPreview(
  BuildContext context, {
  required Map<String, dynamic> bill,
}) {
  final outletJson = bill['outlet'] as Map<String, dynamic>?;
  final companyJson = outletJson?['company'] as Map<String, dynamic>?;
  final vendorJson = bill['vendor'] as Map<String, dynamic>?;

  final company = companyJson != null
      ? Company.fromJson(companyJson)
      : Company(id: 0, name: 'LPG Vendor');
  final outlet = outletJson != null ? Outlet.fromJson(outletJson) : null;

  final lines = _linesFrom(bill);
  final subtotal = asDoubleOrNull(bill['subtotal']) ?? _sumLineSubtotal(lines);
  final tax = asDoubleOrNull(bill['tax_total']) ?? 0;
  final total = asDoubleOrNull(bill['grand_total']) ?? (subtotal + tax);
  final printedOn = DateTime.now();
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';
  final taxSummary = computeTaxSummary(lines.map((l) => (l.taxRate, l.total)));

  var vendorPan = (vendorJson?['pan_vat_no'] as String?) ?? (vendorJson?['vat_reg_number'] as String?) ?? '';
  if (vendorPan == 'N/A' || vendorPan == '-') vendorPan = '';

  final metaRows = [
    [
      ('Bill No', (bill['bill_no'] as String?) ?? '-'),
      ('Vendor Inv. No.', (bill['vendor_invoice_no'] as String?) ?? '-'),
    ],
    [('Bill Date', _formatDate(bill['bill_date'] as String?)), ('Counter No.', counterNo)],
    [('Vendor Name', (vendorJson?['name'] as String?) ?? 'Vendor'), null],
    [('Vendor Pan', vendorPan), null],
  ];

  final documentNo = (bill['bill_no'] as String?) ?? '-';
  final billId = asIntOrNull(bill['id']);
  final printCount = asIntOrNull(bill['print_count']) ?? 0;

  return _showHistoricalDialog(
    context,
    company: company,
    outlet: outlet,
    metaRows: metaRows,
    lines: lines,
    printedOn: printedOn,
    taxSummary: taxSummary,
    subtotal: subtotal,
    tax: tax,
    delivery: 0,
    total: total,
    signatureRightLabel: 'Supplier',
    pdfName: 'Purchase-$documentNo',
    title: 'PURCHASE INVOICE',
    preparedBy: (bill['created_by'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    recordPrintId: billId,
    recordPrint: billId == null ? null : (id) => context.read<PosService>().recordPurchaseBillPrint(id),
    initialPrintCount: printCount,
    isCancelled: bill['status'] == 'cancelled',
  );
}

/// Re-prints a previously posted sales return from its full
/// `GET /admin/sales-returns/{id}` JSON — Recent Bills' Sales Return tab
/// counterpart of [showHistoricalSalesInvoicePreview].
Future<void> showHistoricalSalesReturnPreview(
  BuildContext context, {
  required Map<String, dynamic> salesReturn,
}) {
  final outletJson = salesReturn['outlet'] as Map<String, dynamic>?;
  final companyJson = outletJson?['company'] as Map<String, dynamic>?;
  final customerJson = salesReturn['customer'] as Map<String, dynamic>?;

  final company = companyJson != null
      ? Company.fromJson(companyJson)
      : Company(id: 0, name: 'LPG Vendor');
  final outlet = outletJson != null ? Outlet.fromJson(outletJson) : null;

  final lines = _linesFrom(salesReturn);
  final subtotal = asDoubleOrNull(salesReturn['subtotal']) ?? _sumLineSubtotal(lines);
  final tax = asDoubleOrNull(salesReturn['tax_total']) ?? 0;
  final total = asDoubleOrNull(salesReturn['grand_total']) ?? (subtotal + tax);
  final printedOn = DateTime.now();
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';
  final taxSummary = computeTaxSummary(lines.map((l) => (l.taxRate, l.total)));
  final reason = salesReturn['reason'] as String?;

  final metaRows = [
    [
      ('Return No', (salesReturn['return_no'] as String?) ?? '-'),
      ('Return Date', _formatDate(salesReturn['return_date'] as String?)),
    ],
    [('Counter No.', counterNo), null],
    [('Customer Name', (customerJson?['name'] as String?) ?? 'Walk-in Customer'), null],
    if ((reason ?? '').isNotEmpty) [('Reason', reason!), null],
  ];

  final documentNo = (salesReturn['return_no'] as String?) ?? '-';
  final returnId = asIntOrNull(salesReturn['id']);
  final printCount = asIntOrNull(salesReturn['print_count']) ?? 0;

  return _showHistoricalDialog(
    context,
    company: company,
    outlet: outlet,
    metaRows: metaRows,
    lines: lines,
    printedOn: printedOn,
    taxSummary: taxSummary,
    subtotal: subtotal,
    tax: tax,
    delivery: 0,
    total: total,
    signatureRightLabel: 'Customer',
    pdfName: 'SalesReturn-$documentNo',
    title: 'SALES RETURN',
    initialPrintCount: printCount,
    // Returns/notes stamp whoever is printing right now, not the original
    // creator — matching the backend's ReceiptDocumentFactory's convention
    // for returns (Auth::user(), not a createdBy relation) and the web
    // POS's own historical-return reprint.
    preparedBy: context.read<AuthProvider>().user?.name ?? '',
    recordPrintId: returnId,
    recordPrint: returnId == null ? null : (id) => context.read<PosService>().recordSalesReturnPrint(id),
    isCancelled: salesReturn['status'] == 'cancelled',
  );
}

/// Purchase-return counterpart of [showHistoricalSalesReturnPreview] —
/// vendor fields instead of customer, "Supplier" on the signature line.
Future<void> showHistoricalPurchaseReturnPreview(
  BuildContext context, {
  required Map<String, dynamic> purchaseReturn,
}) {
  final outletJson = purchaseReturn['outlet'] as Map<String, dynamic>?;
  final companyJson = outletJson?['company'] as Map<String, dynamic>?;
  final vendorJson = purchaseReturn['vendor'] as Map<String, dynamic>?;

  final company = companyJson != null
      ? Company.fromJson(companyJson)
      : Company(id: 0, name: 'LPG Vendor');
  final outlet = outletJson != null ? Outlet.fromJson(outletJson) : null;

  final lines = _linesFrom(purchaseReturn);
  final subtotal = asDoubleOrNull(purchaseReturn['subtotal']) ?? _sumLineSubtotal(lines);
  final tax = asDoubleOrNull(purchaseReturn['tax_total']) ?? 0;
  final total = asDoubleOrNull(purchaseReturn['grand_total']) ?? (subtotal + tax);
  final printedOn = DateTime.now();
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';
  final taxSummary = computeTaxSummary(lines.map((l) => (l.taxRate, l.total)));
  final reason = purchaseReturn['reason'] as String?;

  var vendorPan = (vendorJson?['pan_vat_no'] as String?) ?? (vendorJson?['vat_reg_number'] as String?) ?? '';
  if (vendorPan == 'N/A' || vendorPan == '-') vendorPan = '';

  final metaRows = [
    [
      ('Return No', (purchaseReturn['return_no'] as String?) ?? '-'),
      ('Return Date', _formatDate(purchaseReturn['return_date'] as String?)),
    ],
    [('Counter No.', counterNo), null],
    [('Vendor Name', (vendorJson?['name'] as String?) ?? 'Vendor'), null],
    [('Vendor Pan', vendorPan), null],
    if ((reason ?? '').isNotEmpty) [('Reason', reason!), null],
  ];

  final documentNo = (purchaseReturn['return_no'] as String?) ?? '-';
  final returnId = asIntOrNull(purchaseReturn['id']);
  final printCount = asIntOrNull(purchaseReturn['print_count']) ?? 0;

  return _showHistoricalDialog(
    context,
    company: company,
    outlet: outlet,
    metaRows: metaRows,
    lines: lines,
    printedOn: printedOn,
    taxSummary: taxSummary,
    subtotal: subtotal,
    tax: tax,
    delivery: 0,
    total: total,
    signatureRightLabel: 'Supplier',
    pdfName: 'PurchaseReturn-$documentNo',
    title: 'PURCHASE RETURN',
    initialPrintCount: printCount,
    preparedBy: context.read<AuthProvider>().user?.name ?? '',
    recordPrintId: returnId,
    recordPrint: returnId == null ? null : (id) => context.read<PosService>().recordPurchaseReturnPrint(id),
    isCancelled: purchaseReturn['status'] == 'cancelled',
  );
}

Future<void> _showHistoricalDialog(
  BuildContext context, {
  required Company company,
  required Outlet? outlet,
  required List<List<MetaField>> metaRows,
  required List<InvoiceLineData> lines,
  required DateTime printedOn,
  required InvoiceTaxSummary taxSummary,
  required double subtotal,
  required double tax,
  required double delivery,
  required double total,
  required String signatureRightLabel,
  required String pdfName,
  required String? title,
  bool dualInvoiceCopies = false,
  int? recordPrintId,
  Future<void> Function(int id)? recordPrint,
  int initialPrintCount = 0,
  String preparedBy = '',
  bool isCancelled = false,
}) {
  final resolvedTitle = title ?? 'TAX INVOICE';

  const pdfLabels = PosInvoiceLabels(
    phone: _englishPhoneLabel,
    vat: _englishVatLabel,
    srHeader: 'Sr.',
    hsCodeHeader: 'H.S. Code',
    descriptionHeader: 'Description',
    qtyHeader: 'Qty.',
    rateHeader: 'Rate',
    totalAmtHeader: 'Total Amt.',
    printDateTime: 'Print Date/Time :',
    nepaliDate: 'Nepali Date :',
    original: '',
    taxable: 'Taxable :',
    nonTaxable: 'Non Taxable :',
    subTotal: 'Sub Total :',
    discount: 'Discount :',
    vatAmount: 'VAT Amount :',
    vatAmountWithRate: _englishVatAmountWithRate,
    netTotal: 'Net Total :',
    preparedByFallback: 'Prepared By',
    prepareBy: 'Prepare By',
  );

  // Kept mutable so the copy label (Original -> copy-1(original) ->
  // copy-2(original) -> ...) advances on every print made while this same
  // dialog stays open, not just across separate dialog opens.
  var printCount = initialPrintCount;

  return showTaxInvoiceDialog(
    context,
    document: StatefulBuilder(
      builder: (context, setState) {
        final copyLabel = printCopyLabel(printCount + 1);

        final thermalData = ThermalReceiptData(
          companyName: company.name,
          companyAddress: company.address ?? outlet?.address,
          companyPhone: company.phone,
          companyVatNo: company.panVatNo,
          title: resolvedTitle,
          copyLabel: copyLabel,
          metaRows: metaRows,
          items: lines,
          printedAt: printedOn,
          taxable: taxSummary.taxable,
          nonTaxable: taxSummary.nonTaxable,
          subtotal: subtotal,
          vatRateLabel: taxSummary.vatRateLabel,
          tax: tax,
          delivery: delivery,
          total: total,
          preparedBy: preparedBy,
          signatureRightLabel: signatureRightLabel,
          isCancelled: isCancelled,
        );
        // A sales invoice always prints both the tax invoice and the plain
        // invoice copy together, as a single print action.
        final invoiceCopyData = dualInvoiceCopies
            ? ThermalReceiptData(
                companyName: company.name,
                companyAddress: company.address ?? outlet?.address,
                companyPhone: company.phone,
                companyVatNo: company.panVatNo,
                title: 'INVOICE',
                copyLabel: copyLabel,
                metaRows: metaRows,
                items: lines,
                printedAt: printedOn,
                taxable: taxSummary.taxable,
                nonTaxable: taxSummary.nonTaxable,
                subtotal: subtotal,
                vatRateLabel: taxSummary.vatRateLabel,
                tax: tax,
                delivery: delivery,
                total: total,
                preparedBy: preparedBy,
                signatureRightLabel: signatureRightLabel,
                isCancelled: isCancelled,
              )
            : null;

        Future<Uint8List> buildPdf() => dualInvoiceCopies
            ? buildInvoicePdfBytesForCopies(
                companyName: company.name,
                companyAddress: company.address ?? outlet?.address,
                companyPhone: company.phone,
                companyVatNo: company.panVatNo,
                metaRows: metaRows,
                items: lines,
                printedAt: printedOn,
                taxable: taxSummary.taxable,
                nonTaxable: taxSummary.nonTaxable,
                subtotal: subtotal,
                vatRateLabel: taxSummary.vatRateLabel,
                tax: tax,
                delivery: delivery,
                total: total,
                preparedBy: preparedBy,
                signatureRightLabel: signatureRightLabel,
                labels: pdfLabels,
                copies: [('TAX INVOICE', copyLabel), ('INVOICE', copyLabel)],
                isCancelled: isCancelled,
              )
            : buildInvoicePdfBytes(
                companyName: company.name,
                companyAddress: company.address ?? outlet?.address,
                companyPhone: company.phone,
                companyVatNo: company.panVatNo,
                title: resolvedTitle,
                copyLabel: copyLabel,
                metaRows: metaRows,
                items: lines,
                printedAt: printedOn,
                taxable: taxSummary.taxable,
                nonTaxable: taxSummary.nonTaxable,
                subtotal: subtotal,
                vatRateLabel: taxSummary.vatRateLabel,
                tax: tax,
                delivery: delivery,
                total: total,
                preparedBy: preparedBy,
                signatureRightLabel: signatureRightLabel,
                labels: pdfLabels,
                isCancelled: isCancelled,
              );

        Future<void> markPrinted() async {
          if (recordPrintId != null && recordPrint != null && context.mounted) {
            await recordPrint(recordPrintId);
            setState(() => printCount++);
          }
        }

        return TaxInvoiceDocument(
          companyName: company.name,
          companyAddress: company.address ?? outlet?.address,
          companyPhone: company.phone,
          companyVatNo: company.panVatNo,
          title: resolvedTitle,
          copyLabel: copyLabel,
          metaRows: metaRows,
          items: lines,
          printedAt: printedOn,
          taxable: taxSummary.taxable,
          nonTaxable: taxSummary.nonTaxable,
          subtotal: subtotal,
          vatRateLabel: taxSummary.vatRateLabel,
          tax: tax,
          delivery: delivery,
          total: total,
          preparedBy: preparedBy,
          signatureRightLabel: signatureRightLabel,
          isCancelled: isCancelled,
          actions: [
            ElevatedButton.icon(
              onPressed: () => showPrintMethodSheet(
                context,
                onThermalPrint: () async {
                  await printBillOnThermalPrinter(
                    context,
                    data: thermalData,
                    extraCopies: invoiceCopyData != null ? [invoiceCopyData] : const [],
                  );
                  await markPrinted();
                },
                onPdfPrint: () async {
                  await Printing.layoutPdf(onLayout: (_) => buildPdf(), name: pdfName);
                  await markPrinted();
                },
              ),
              style: AppButtonStyles.filled(AppColors.info).copyWith(
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
              ),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print'),
            ),
            ElevatedButton.icon(
              onPressed: () async => Printing.sharePdf(bytes: await buildPdf(), filename: '$pdfName.pdf'),
              style: AppButtonStyles.filled(AppColors.info).copyWith(
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
              ),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppButtonStyles.filled(AppColors.textFaint).copyWith(
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    ),
  );
}

/// `lines[]` -> `InvoiceLineData`, deriving each line's tax rate from
/// `tax_amount`/`line_total` (tax-inclusive) the same way the backend's
/// `ReceiptDocumentFactory::splitTaxable` does, since the detail JSON
/// doesn't carry a plain percentage field.
List<InvoiceLineData> _linesFrom(Map<String, dynamic> document) {
  final rawLines = (document['lines'] as List?) ?? const [];
  return rawLines.map((raw) {
    final line = raw as Map<String, dynamic>;
    final product = line['product'] as Map<String, dynamic>?;
    final qty = asDouble(line['qty']);
    final rate = asDouble(line['rate']);
    final lineTotal = asDoubleOrNull(line['line_total']) ?? qty * rate;
    final taxAmount = asDoubleOrNull(line['tax_amount']) ?? 0;
    final base = lineTotal - taxAmount;
    final taxRate = base > 0 ? (taxAmount / base) * 100 : 0.0;

    return InvoiceLineData(
      hsCode: (product?['hs_code'] as String?) ?? '',
      description: (product?['name'] as String?) ?? '-',
      qty: qty,
      rate: rate,
      total: base > 0 ? base : lineTotal,
      taxRate: taxRate,
    );
  }).toList();
}

double _sumLineSubtotal(List<InvoiceLineData> lines) => lines.fold(0.0, (sum, l) => sum + l.total);

String _formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '-';
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  final label = nepaliDateLabel(parsed);
  return label.isEmpty ? '${parsed.day}/${parsed.month}/${parsed.year}' : label;
}

String _englishPhoneLabel(String phone) => 'Phone No : $phone';
String _englishVatLabel(String vatNo) => 'VAT # : $vatNo';
String _englishVatAmountWithRate(String rate) => 'VAT Amount ($rate) :';
