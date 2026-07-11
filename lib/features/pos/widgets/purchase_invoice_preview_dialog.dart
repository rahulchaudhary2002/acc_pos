import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/company.dart';
import '../models/outlet.dart';
import '../models/purchase_cart_item.dart';
import '../models/transaction_result.dart';
import '../utils/invoice_format_utils.dart';
import '../utils/invoice_pdf.dart';
import 'invoice_document.dart';

/// Post-purchase receipt — mirrors the purchase "TAX INVOICE" preview modal
/// in `PosTerminal.jsx` (same layout as the sale receipt, but with vendor
/// fields, no Print button, and "Supplier" on the signature line).
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
  final l10n = AppLocalizations.of(context)!;

  final metaRows = [
    [
      (l10n.purchaseInvoicePreviewBillNoLabel, result.billNo ?? result.documentNo),
      (l10n.purchaseInvoicePreviewVendorInvNoLabel, (vendorInvoiceNo ?? '').isNotEmpty ? vendorInvoiceNo! : '-'),
    ],
    [(l10n.purchaseInvoicePreviewBillDateLabel, _formatDate(billDate)), (l10n.purchaseInvoicePreviewMrnNoLabel, result.documentNo)],
    [(l10n.purchaseInvoicePreviewVendorNameLabel, vendorName), (l10n.invoicePreviewCounterNoLabel, counterNo)],
    if ((vendorVatNumber ?? '').isNotEmpty) [(l10n.purchaseInvoicePreviewVendorPanLabel, vendorVatNumber!), null],
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
        signatureRightLabel: l10n.purchaseInvoicePreviewSignatureSupplierLabel,
        title: l10n.purchaseInvoicePreviewTitle,
        labels: PosInvoiceLabels(
          phone: l10n.posInvoicePhoneLabel,
          vat: l10n.posInvoiceVatLabel,
          srHeader: l10n.posInvoiceSrHeader,
          hsCodeHeader: l10n.posInvoiceHsCodeHeader,
          descriptionHeader: l10n.posInvoiceDescriptionHeader,
          qtyHeader: l10n.posInvoiceQtyHeader,
          rateHeader: l10n.posInvoiceRateHeader,
          totalAmtHeader: l10n.posInvoiceTotalAmtHeader,
          printDateTime: l10n.posInvoicePrintDateTimeLabel,
          nepaliDate: l10n.posInvoiceNepaliDateLabel,
          original: l10n.posInvoiceOriginalLabel,
          taxable: l10n.posInvoiceTaxableLabel,
          nonTaxable: l10n.posInvoiceNonTaxableLabel,
          subTotal: l10n.posInvoiceSubTotalLabel,
          discount: l10n.posInvoiceDiscountLabel,
          vatAmount: l10n.posInvoiceVatAmountLabel,
          vatAmountWithRate: l10n.posInvoiceVatAmountWithRateLabel,
          netTotal: l10n.posInvoiceNetTotalLabel,
          preparedByFallback: l10n.posInvoicePreparedByFallback,
          prepareBy: l10n.posInvoicePrepareByLabel,
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
      signatureRightLabel: l10n.purchaseInvoicePreviewSignatureSupplierLabel,
      title: l10n.purchaseInvoicePreviewTitle,
      actions: [
        ElevatedButton.icon(
          onPressed: () async => Printing.sharePdf(bytes: await buildPdf(), filename: 'Purchase-${result.billNo ?? result.documentNo}.pdf'),
          style: AppButtonStyles.filled(AppColors.share).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          icon: const Icon(Icons.share, size: 18),
          label: Text(l10n.purchaseInvoicePreviewShareButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: AppButtonStyles.filled(AppColors.textFaint).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          child: Text(l10n.purchaseInvoicePreviewCloseButton),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
