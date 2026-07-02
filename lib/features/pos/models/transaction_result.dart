import 'json_utils.dart';

/// Shared response shape for sell/buy/sell-return/purchase-return —
/// all of these return `{data: {..., grand_total|net_total, status}, message}`.
class TransactionResult {
  final String documentNo;
  final int documentId;
  final double total;
  final double? subtotal;
  final double? taxTotal;
  final double? delivery;
  final String status;
  final String message;

  TransactionResult({
    required this.documentNo,
    required this.documentId,
    required this.total,
    this.subtotal,
    this.taxTotal,
    this.delivery,
    required this.status,
    required this.message,
  });

  factory TransactionResult.fromSellJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TransactionResult(
      documentNo: data['invoice_no'] as String,
      documentId: asInt(data['invoice_id']),
      total: (data['grand_total'] as num).toDouble(),
      subtotal: (data['subtotal'] as num?)?.toDouble(),
      taxTotal: (data['tax_total'] as num?)?.toDouble(),
      delivery: (data['delivery'] as num?)?.toDouble(),
      status: data['status'] as String,
      message: json['message'] as String? ?? '',
    );
  }

  factory TransactionResult.fromBuyJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TransactionResult(
      documentNo: data['grn_no'] as String,
      documentId: asInt(data['grn_id']),
      total: (data['net_total'] as num).toDouble(),
      status: data['status'] as String,
      message: json['message'] as String? ?? '',
    );
  }

  factory TransactionResult.fromReturnJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TransactionResult(
      documentNo: data['return_no'] as String,
      documentId: asInt(data['return_id']),
      total: (data['grand_total'] as num).toDouble(),
      subtotal: (data['subtotal'] as num?)?.toDouble(),
      taxTotal: (data['tax_total'] as num?)?.toDouble(),
      status: data['status'] as String,
      message: json['message'] as String? ?? '',
    );
  }
}
