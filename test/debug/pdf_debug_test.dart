import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:acc_pos/features/pos/utils/invoice_pdf.dart';
import 'package:acc_pos/features/pos/widgets/invoice_document.dart';

void main() {
  test('generate cancelled invoice pdf for visual inspection', () async {
    const labels = PosInvoiceLabels(
      phone: _phone,
      vat: _vat,
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
      vatAmountWithRate: _vatAmountWithRate,
      netTotal: 'Net Total :',
      preparedByFallback: 'Prepared By',
      prepareBy: 'Prepare By',
    );

    final bytes = await buildInvoicePdfBytes(
      companyName: 'CHANDRA BINAYAK GAS STORE',
      companyAddress: 'Chabahil, Kathmandu, Nepal',
      companyPhone: '014577991',
      companyVatNo: '603821910',
      title: 'TAX INVOICE',
      copyLabel: 'Original',
      metaRows: [
        [('Invoice No', 'CBKG-180'), ('Ref. No.', 'CBKG-180')],
        [('Invoice Date', '12/04/2083 BS'), ('Counter No.', 'DEFAULT')],
        [('Customer Name', 'Walk-in Customer'), ('Payment Mode', 'cash')],
      ],
      items: const [
        InvoiceLineData(hsCode: '27111900', description: 'Cylinder 14.2 kg', qty: 1, rate: 1823.01, total: 1823.01, taxRate: 13),
      ],
      printedAt: DateTime(2026, 7, 28, 16, 33),
      taxable: 1823.01,
      nonTaxable: 0,
      subtotal: 1823.01,
      vatRateLabel: '13%',
      tax: 236.99,
      total: 2060.00,
      preparedBy: 'Admin',
      signatureRightLabel: 'Customer',
      labels: labels,
      isCancelled: true,
    );

    final file = File('/tmp/mobile_cancelled_invoice.pdf');
    await file.writeAsBytes(bytes);
    // ignore: avoid_print
    print('Wrote ${bytes.length} bytes to ${file.path}');
  });
}

String _phone(String phone) => 'Phone No : $phone';
String _vat(String vatNo) => 'VAT # : $vatNo';
String _vatAmountWithRate(String rate) => 'VAT Amount ($rate%) :';
