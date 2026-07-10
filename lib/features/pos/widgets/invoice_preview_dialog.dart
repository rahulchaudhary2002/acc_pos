import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/sale_cart_item.dart';
import '../models/transaction_result.dart';

/// Post-checkout receipt, mirroring the "TAX INVOICE" preview modal in
/// `PosTerminal.jsx`: metadata grid, line items table, VAT summary, actions.
Future<void> showInvoicePreview(
  BuildContext context, {
  required TransactionResult result,
  required List<SaleCartItem> items,
  required String companyName,
  String? customerName,
  required String paymentMode,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.overlayScrim,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.section),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  companyName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'TAX INVOICE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                ),
                const SizedBox(height: AppSpacing.card),
                _metaRow('Invoice No.', result.documentNo),
                _metaRow('Customer Name', customerName ?? 'Walk-in Customer'),
                _metaRow('Payment Mode', paymentMode == 'cash' ? 'Cash' : 'Credit'),
                const SizedBox(height: AppSpacing.card),
                Table(
                  border: TableBorder.all(color: AppColors.textPrimary, width: 1.2),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(1.4),
                  },
                  children: [
                    const TableRow(children: [
                      _TableCell('Description', bold: true),
                      _TableCell('Qty.', bold: true),
                      _TableCell('Rate', bold: true),
                      _TableCell('Total', bold: true),
                    ]),
                    ...items.map(
                      (item) => TableRow(children: [
                        _TableCell(item.product.name),
                        _TableCell(item.qty.toStringAsFixed(item.qty.truncateToDouble() == item.qty ? 0 : 2)),
                        _TableCell(item.rate.toStringAsFixed(2)),
                        _TableCell(item.lineTotal.toStringAsFixed(2)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.card),
                _summaryRow('Sub Total', result.subtotal ?? 0),
                _summaryRow('VAT Amount', result.taxTotal ?? 0),
                if ((result.delivery ?? 0) > 0) _summaryRow('Delivery', result.delivery!),
                const Divider(),
                _summaryRow('Net Total', result.total, bold: true),
                const SizedBox(height: AppSpacing.section),
                Wrap(
                  spacing: AppSpacing.field,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: AppButtonStyles.filled(AppColors.info).copyWith(
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
                      ),
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print'),
                    ),
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
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _metaRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

Widget _summaryRow(String label, double value, {bool bold = false}) {
  final style = TextStyle(fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('Rs ${value.toStringAsFixed(2)}', style: style),
      ],
    ),
  );
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _TableCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
      ),
    );
  }
}
