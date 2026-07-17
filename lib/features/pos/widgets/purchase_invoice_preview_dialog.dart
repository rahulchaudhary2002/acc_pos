import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/company.dart';
import '../models/outlet.dart';
import '../models/purchase_cart_item.dart';
import '../models/transaction_result.dart';
import '../utils/invoice_format_utils.dart';
import '../utils/invoice_pdf.dart';
import '../utils/thermal_receipt_builder.dart';
import 'invoice_document.dart';
import 'printer_picker_sheet.dart';

/// Post-purchase receipt — mirrors the purchase "TAX INVOICE" preview modal
/// in `PosTerminal.jsx` (same layout as the sale receipt, but with vendor
/// fields and "Supplier" on the signature line).
Future<void> showPurchaseInvoicePreview(
  BuildContext context, {
  required TransactionResult result,
  required List<PurchaseCartItem> items,
  required Company company,
  Outlet? outlet,
  required String vendorName,
  String? vendorVatNumber,
  String? vendorInvoiceNo,
  required DateTime billDate,
  String? preparedBy,
}) {
  final now = DateTime.now();
  final itemsSubtotal = items.fold(0.0, (sum, i) => sum + i.lineTotal);
  final subtotal = result.subtotal ?? itemsSubtotal;
  final tax = result.taxTotal ?? 0;
  final taxSummary = computeTaxSummary(items.map((i) => (i.product.taxRate, i.lineTotal)));
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';

  final metaRows = [
    [
      ('Bill No', result.billNo ?? result.documentNo),
      ('Vendor Inv. No.', (vendorInvoiceNo ?? '').isNotEmpty ? vendorInvoiceNo! : '-'),
    ],
    [('Bill Date', _formatDate(billDate)), ('MRN No.', result.documentNo)],
    [('Vendor Name', vendorName), ('Counter No.', counterNo)],
    if ((vendorVatNumber ?? '').isNotEmpty) [('Vendor Pan', vendorVatNumber!), null],
  ];
  final invoiceLines = items
      .map((i) => InvoiceLineData(
            hsCode: i.product.hsCode ?? '',
            description: i.product.name,
            qty: i.qty,
            rate: i.unitCost,
            total: i.lineTotal,
            taxRate: i.product.taxRate,
          ))
      .toList();

  final thermalData = ThermalReceiptData(
    companyName: company.name,
    companyAddress: company.address ?? outlet?.address,
    companyPhone: company.phone,
    companyVatNo: company.panVatNo,
    title: 'PURCHASE INVOICE',
    metaRows: metaRows,
    items: invoiceLines,
    printedAt: now,
    taxable: taxSummary.taxable,
    nonTaxable: taxSummary.nonTaxable,
    subtotal: subtotal,
    vatRateLabel: taxSummary.vatRateLabel,
    tax: tax,
    total: subtotal + tax,
    preparedBy: preparedBy ?? '',
    signatureRightLabel: 'Supplier',
  );

  Future<Uint8List> buildPdf() => buildInvoicePdfBytes(
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
        total: subtotal + tax,
        preparedBy: preparedBy ?? '',
        signatureRightLabel: 'Supplier',
        title: 'PURCHASE INVOICE',
        labels: const PosInvoiceLabels(
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
          original: 'Original',
          taxable: 'Taxable :',
          nonTaxable: 'Non Taxable :',
          subTotal: 'Sub Total :',
          discount: 'Discount :',
          vatAmount: 'VAT Amount :',
          vatAmountWithRate: _englishVatAmountWithRate,
          netTotal: 'Net Total :',
          preparedByFallback: 'Prepared By',
          prepareBy: 'Prepare By',
        ),
      );

  return showTaxInvoiceDialog(
    context,
    document: TaxInvoiceDocument(
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
      total: subtotal + tax,
      preparedBy: preparedBy ?? '',
      signatureRightLabel: 'Supplier',
      title: 'PURCHASE INVOICE',
      actions: [
        ElevatedButton.icon(
          onPressed: () => printBillOnThermalPrinter(context, data: thermalData),
          style: AppButtonStyles.filled(AppColors.success).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          icon: const Icon(Icons.receipt_long, size: 18),
          label: const Text('Print Bill'),
        ),
        ElevatedButton.icon(
          onPressed: () async => Printing.layoutPdf(onLayout: (_) => buildPdf(), name: 'Purchase-${result.billNo ?? result.documentNo}'),
          style: AppButtonStyles.filled(AppColors.info).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Print'),
        ),
        ElevatedButton.icon(
          onPressed: () async => Printing.sharePdf(bytes: await buildPdf(), filename: 'Purchase-${result.billNo ?? result.documentNo}.pdf'),
          style: AppButtonStyles.filled(AppColors.share).copyWith(
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
