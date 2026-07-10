import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/company.dart';
import '../models/outlet.dart';
import '../models/purchase_cart_item.dart';
import '../models/transaction_result.dart';
import '../utils/invoice_format_utils.dart';
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

  return showTaxInvoiceDialog(
    context,
    document: TaxInvoiceDocument(
      companyName: company.name,
      companyAddress: company.address ?? outlet?.address,
      companyPhone: company.phone,
      companyVatNo: company.panVatNo,
      metaRows: [
        [
          ('Bill No', result.billNo ?? result.documentNo),
          ('Vendor Inv. No.', (vendorInvoiceNo ?? '').isNotEmpty ? vendorInvoiceNo! : '-'),
        ],
        [('Bill Date', _formatDate(billDate)), ('MRN No.', result.documentNo)],
        [('Vendor Name', vendorName), ('Counter No.', counterNo)],
        if ((vendorVatNumber ?? '').isNotEmpty) [('Vendor Pan', vendorVatNumber!), null],
      ],
      items: items
          .map((i) => InvoiceLineData(
                hsCode: i.product.hsCode ?? '',
                description: i.product.name,
                qty: i.qty,
                rate: i.unitCost,
                total: i.lineTotal,
                taxRate: i.product.taxRate,
              ))
          .toList(),
      printedAt: now,
      taxable: taxSummary.taxable,
      nonTaxable: taxSummary.nonTaxable,
      subtotal: subtotal,
      vatRateLabel: taxSummary.vatRateLabel,
      tax: tax,
      total: subtotal + tax,
      preparedBy: preparedBy ?? '',
      signatureRightLabel: 'Supplier',
      actions: [
        ElevatedButton.icon(
          onPressed: () {},
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
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
