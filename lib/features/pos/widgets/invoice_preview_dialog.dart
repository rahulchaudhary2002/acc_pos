import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/company.dart';
import '../models/outlet.dart';
import '../models/sale_cart_item.dart';
import '../models/transaction_result.dart';
import '../services/pos_service.dart';
import '../utils/invoice_format_utils.dart';
import '../utils/invoice_pdf.dart';
import '../utils/thermal_receipt_builder.dart';
import 'invoice_document.dart';
import 'printer_picker_sheet.dart';

/// Post-sale receipt — mirrors the "TAX INVOICE" preview modal in
/// `PosTerminal.jsx`: company header, metadata grid, line items table, VAT
/// summary, amount-in-words, signature block, and actions.
Future<void> showInvoicePreview(
  BuildContext context, {
  required TransactionResult result,
  required List<SaleCartItem> items,
  required Company company,
  Outlet? outlet,
  String? customerName,
  String? customerVatNumber,
  required String paymentMode,
  String? paymentReference,
  String? paymentNote,
  String? preparedBy,
  double deliveryCharge = 0,
}) {
  final now = DateTime.now();
  // The web receipt renders its client-side `sellTotals` snapshot, not the
  // server response: subtotal = Σ qty×rate, tax = Σ unrounded line tax,
  // total = subtotal + tax + delivery. Its taxable/non-taxable split sums
  // tax-EXCLUSIVE line amounts (snapshot lines carry total = qty × rate).
  final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineSubtotal);
  final tax = items.fold<double>(0, (sum, i) => sum + i.taxAmount);
  final grandTotal = subtotal + tax + deliveryCharge;
  final taxSummary = computeTaxSummary(items.map((i) => (i.taxRate, i.lineSubtotal)));
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';

  final metaRows = [
    [('Invoice No', result.documentNo), ('Ref. No.', result.documentNo)],
    [('Invoice Date', _formatDate(now)), ('Counter No.', counterNo)],
    [
      ('Customer Name', customerName ?? 'Walk-in Customer'),
      ('Payment Mode', paymentMode == 'cash' ? 'Cash' : 'Credit'),
    ],
    [('Customer Pan', customerVatNumber ?? ''), null],
    if ((paymentReference ?? '').isNotEmpty || (paymentNote ?? '').isNotEmpty)
      [
        (paymentReference ?? '').isNotEmpty ? ('Payment Ref.', paymentReference!) : null,
        (paymentNote ?? '').isNotEmpty ? ('Payment Note', paymentNote!) : null,
      ],
  ];
  final invoiceLines = items
      .map((i) => InvoiceLineData(
            hsCode: i.product.hsCode ?? '',
            description: i.product.name,
            qty: i.qty,
            rate: i.rate,
            // Web invoice line rows show qty × rate (tax-exclusive).
            total: i.lineSubtotal,
            taxRate: i.taxRate,
          ))
      .toList();

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

  // Kept mutable so the copy label (blank -> Copy of Original (1) ->
  // Copy of Original (2) -> ...) advances on every print made while this same
  // just-completed-sale dialog stays open, not just across separate opens.
  var printCount = 0;

  return showTaxInvoiceDialog(
    context,
    document: StatefulBuilder(
      builder: (context, setState) {
        final copyLabel = printCopyLabel(printCount + 1);
        // Only the very first print hands over both the tax invoice and the
        // plain invoice copy together, as a single print action. Every
        // reprint after that is a single page — no "TAX INVOICE"/"INVOICE"
        // title, just the "Copy of Original (N)" label.
        final isFirstPrint = printCount == 0;

        final thermalData = ThermalReceiptData(
          companyName: company.name,
          companyAddress: company.address ?? outlet?.address,
          companyPhone: company.phone,
          companyVatNo: company.panVatNo,
          title: isFirstPrint ? 'TAX INVOICE' : '',
          copyLabel: copyLabel,
          metaRows: metaRows,
          items: invoiceLines,
          printedAt: now,
          taxable: taxSummary.taxable,
          nonTaxable: taxSummary.nonTaxable,
          subtotal: subtotal,
          vatRateLabel: taxSummary.vatRateLabel,
          tax: tax,
          delivery: deliveryCharge,
          total: grandTotal,
          preparedBy: preparedBy ?? '',
          signatureRightLabel: 'Customer',
        );
        final invoiceCopyData = ThermalReceiptData(
          companyName: company.name,
          companyAddress: company.address ?? outlet?.address,
          companyPhone: company.phone,
          companyVatNo: company.panVatNo,
          title: 'INVOICE',
          copyLabel: copyLabel,
          metaRows: metaRows,
          items: invoiceLines,
          printedAt: now,
          taxable: taxSummary.taxable,
          nonTaxable: taxSummary.nonTaxable,
          subtotal: subtotal,
          vatRateLabel: taxSummary.vatRateLabel,
          tax: tax,
          delivery: deliveryCharge,
          total: grandTotal,
          preparedBy: preparedBy ?? '',
          signatureRightLabel: 'Customer',
        );

        Future<Uint8List> buildPdf() => buildInvoicePdfBytesForCopies(
              companyName: company.name,
              companyAddress: company.address ?? outlet?.address,
              companyPhone: company.phone,
              companyVatNo: company.panVatNo,
              metaRows: metaRows,
              items: invoiceLines,
              printedAt: now,
              taxable: taxSummary.taxable,
              nonTaxable: taxSummary.nonTaxable,
              subtotal: subtotal,
              vatRateLabel: taxSummary.vatRateLabel,
              tax: tax,
              delivery: deliveryCharge,
              total: grandTotal,
              preparedBy: preparedBy ?? '',
              signatureRightLabel: 'Customer',
              labels: pdfLabels,
              copies: isFirstPrint ? [('TAX INVOICE', copyLabel), ('INVOICE', copyLabel)] : [('', copyLabel)],
            );

        Future<void> markPrinted() async {
          if (context.mounted) {
            await context.read<PosService>().recordSalesInvoicePrint(result.documentId);
            setState(() => printCount++);
          }
        }

        return TaxInvoiceDocument(
          companyName: company.name,
          companyAddress: company.address ?? outlet?.address,
          companyPhone: company.phone,
          companyVatNo: company.panVatNo,
          title: isFirstPrint ? 'TAX INVOICE' : '',
          copyLabel: copyLabel,
          metaRows: metaRows,
          items: invoiceLines,
          printedAt: now,
          taxable: taxSummary.taxable,
          nonTaxable: taxSummary.nonTaxable,
          subtotal: subtotal,
          vatRateLabel: taxSummary.vatRateLabel,
          tax: tax,
          delivery: deliveryCharge,
          total: grandTotal,
          preparedBy: preparedBy ?? '',
          signatureRightLabel: 'Customer',
          actions: [
            ElevatedButton.icon(
              onPressed: () => showPrintMethodSheet(
                context,
                onThermalPrint: () async {
                  await printBillOnThermalPrinter(
                    context,
                    data: thermalData,
                    extraCopies: isFirstPrint ? [invoiceCopyData] : [],
                  );
                  await markPrinted();
                },
                onPdfPrint: () async {
                  await Printing.layoutPdf(onLayout: (_) => buildPdf(), name: 'Invoice-${result.documentNo}');
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
              onPressed: () async =>
                  Printing.sharePdf(bytes: await buildPdf(), filename: 'Invoice-${result.documentNo}.pdf'),
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

String _formatDate(DateTime date) {
  final label = nepaliDateLabel(date);
  return label.isEmpty ? '${date.day}/${date.month}/${date.year}' : label;
}

String _englishPhoneLabel(String phone) => 'Phone No : $phone';
String _englishVatLabel(String vatNo) => 'VAT # : $vatNo';
String _englishVatAmountWithRate(String rate) => 'VAT Amount ($rate) :';
