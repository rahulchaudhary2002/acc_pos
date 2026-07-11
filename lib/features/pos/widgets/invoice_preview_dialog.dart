import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/company.dart';
import '../models/outlet.dart';
import '../models/sale_cart_item.dart';
import '../models/transaction_result.dart';
import '../utils/invoice_format_utils.dart';
import '../utils/invoice_pdf.dart';
import 'invoice_document.dart';

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
}) {
  final now = DateTime.now();
  final taxSummary = computeTaxSummary(items.map((i) => (i.taxRate, i.lineTotal)));
  final counterNo = outlet?.code ?? outlet?.id.toString() ?? '';
  final l10n = AppLocalizations.of(context)!;

  final metaRows = [
    [(l10n.invoicePreviewInvoiceNoLabel, result.documentNo), (l10n.invoicePreviewRefNoLabel, result.documentNo)],
    [(l10n.invoicePreviewInvoiceDateLabel, _formatDate(now)), (l10n.invoicePreviewCounterNoLabel, counterNo)],
    [
      (l10n.invoicePreviewCustomerNameLabel, customerName ?? l10n.invoicePreviewWalkInCustomer),
      (l10n.invoicePreviewPaymentModeLabel, paymentMode == 'cash' ? l10n.invoicePreviewCashLabel : l10n.invoicePreviewCreditLabel),
    ],
    [(l10n.invoicePreviewCustomerPanLabel, customerVatNumber ?? ''), null],
    if ((paymentReference ?? '').isNotEmpty || (paymentNote ?? '').isNotEmpty)
      [
        (paymentReference ?? '').isNotEmpty ? (l10n.invoicePreviewPaymentRefLabel, paymentReference!) : null,
        (paymentNote ?? '').isNotEmpty ? (l10n.invoicePreviewPaymentNoteLabel, paymentNote!) : null,
      ],
  ];
  final invoiceLines = items
      .map((i) => InvoiceLineData(
            hsCode: i.product.hsCode ?? '',
            description: i.product.name,
            qty: i.qty,
            rate: i.rate,
            total: i.lineTotal,
            taxRate: i.taxRate,
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
        subtotal: result.subtotal ?? 0,
        vatRateLabel: taxSummary.vatRateLabel,
        tax: result.taxTotal ?? 0,
        total: result.total,
        preparedBy: preparedBy ?? '',
        signatureRightLabel: l10n.invoicePreviewSignatureCustomerLabel,
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
      subtotal: result.subtotal ?? 0,
      vatRateLabel: taxSummary.vatRateLabel,
      tax: result.taxTotal ?? 0,
      total: result.total,
      preparedBy: preparedBy ?? '',
      signatureRightLabel: l10n.invoicePreviewSignatureCustomerLabel,
      actions: [
        ElevatedButton.icon(
          onPressed: () async => Printing.layoutPdf(onLayout: (_) => buildPdf(), name: 'Invoice-${result.documentNo}'),
          style: AppButtonStyles.filled(AppColors.info).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          icon: const Icon(Icons.print, size: 18),
          label: Text(l10n.invoicePreviewPrintButton),
        ),
        ElevatedButton.icon(
          onPressed: () async => Printing.sharePdf(bytes: await buildPdf(), filename: 'Invoice-${result.documentNo}.pdf'),
          style: AppButtonStyles.filled(AppColors.share).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          icon: const Icon(Icons.share, size: 18),
          label: Text(l10n.invoicePreviewShareButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: AppButtonStyles.filled(AppColors.textFaint).copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
          ),
          child: Text(l10n.invoicePreviewCloseButton),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
