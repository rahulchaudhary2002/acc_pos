import 'json_utils.dart';

/// A row from `GET /pos/sales-list` or `GET /pos/purchases-list`.
class TransactionSummary {
  final int id;
  final String documentNo;
  final String date;
  final String? partyName;
  final double total;

  /// Secondary label: `payment_mode` for sales, `bill_no` for purchases.
  final String subtitle;

  TransactionSummary({
    required this.id,
    required this.documentNo,
    required this.date,
    this.partyName,
    required this.total,
    required this.subtitle,
  });

  // `sales-list`/`purchases-list` are raw query-builder selects, so decimal
  // columns (grand_total, net_total) come back as strings (e.g. "2084.0000").
  static double _asDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());

  factory TransactionSummary.fromSaleJson(Map<String, dynamic> json) {
    return TransactionSummary(
      id: asInt(json['id']),
      documentNo: json['invoice_no'] as String? ?? '',
      date: json['invoice_date'] as String? ?? '',
      partyName: json['customer_name'] as String?,
      total: _asDouble(json['grand_total']),
      subtitle: json['payment_mode'] as String? ?? '',
    );
  }

  factory TransactionSummary.fromPurchaseJson(Map<String, dynamic> json) {
    return TransactionSummary(
      id: asInt(json['id']),
      documentNo: json['grn_no'] as String? ?? '',
      date: json['grn_date'] as String? ?? '',
      partyName: json['vendor_name'] as String?,
      total: _asDouble(json['net_total']),
      subtitle: json['bill_no'] as String? ?? '',
    );
  }
}
