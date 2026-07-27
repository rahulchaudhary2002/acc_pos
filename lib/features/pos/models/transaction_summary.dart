import 'json_utils.dart';

/// A history row from `GET /admin/sales-invoices` or
/// `GET /admin/purchase-bills` — the same listings the web consumes.
class TransactionSummary {
  final int id;
  final String documentNo;
  final String date;
  final String? partyName;
  final double total;

  /// Secondary label: `payment_mode` for sales, `vendor_invoice_no` for purchases.
  final String subtitle;

  /// Server `created_at` timestamp (when the record was actually posted),
  /// distinct from [date] (the invoice/bill date the user picked) — used by
  /// the Recent Bills screen's rolling 24-hour cutoff.
  final DateTime? createdAt;

  TransactionSummary({
    required this.id,
    required this.documentNo,
    required this.date,
    this.partyName,
    required this.total,
    required this.subtitle,
    this.createdAt,
  });

  factory TransactionSummary.fromSaleJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return TransactionSummary(
      id: asInt(json['id']),
      documentNo: json['invoice_no'] as String? ?? '',
      date: json['invoice_date'] as String? ?? '',
      partyName: customer?['name'] as String?,
      total: asDoubleOrNull(json['grand_total']) ?? 0,
      subtitle: json['payment_mode'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  factory TransactionSummary.fromPurchaseJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    return TransactionSummary(
      id: asInt(json['id']),
      documentNo: json['bill_no'] as String? ?? '',
      date: json['bill_date'] as String? ?? '',
      partyName: vendor?['name'] as String?,
      total: asDoubleOrNull(json['grand_total']) ?? 0,
      subtitle: json['vendor_invoice_no'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
