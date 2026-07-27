import 'json_utils.dart';

/// A row from `GET /admin/reports/vat-summary` — one per tax code, with
/// input (purchase) and output (sales) VAT totals for the selected range.
class VatSummaryRow {
  final int taxCodeId;
  final String name;
  final double rate;
  final double inputTax;
  final double outputTax;

  VatSummaryRow({
    required this.taxCodeId,
    required this.name,
    required this.rate,
    required this.inputTax,
    required this.outputTax,
  });

  /// Positive = VAT payable to the tax authority, negative = refundable.
  double get net => outputTax - inputTax;

  factory VatSummaryRow.fromJson(Map<String, dynamic> json) {
    return VatSummaryRow(
      taxCodeId: asInt(json['tax_code_id']),
      name: json['name'] as String? ?? '-',
      rate: asDoubleOrNull(json['rate']) ?? 0,
      inputTax: asDoubleOrNull(json['input_tax']) ?? 0,
      outputTax: asDoubleOrNull(json['output_tax']) ?? 0,
    );
  }
}
