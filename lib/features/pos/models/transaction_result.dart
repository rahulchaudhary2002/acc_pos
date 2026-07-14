/// Uniform result for sell / buy / sell-return / purchase-return, built by
/// [PosService] from the `/api/admin/*` responses (the same endpoints the
/// web POS uses).
class TransactionResult {
  final String documentNo;
  final int documentId;
  final double total;
  final double? subtotal;
  final double? taxTotal;
  final double? delivery;
  final String? billNo;
  final String status;
  final String message;

  TransactionResult({
    required this.documentNo,
    required this.documentId,
    required this.total,
    this.subtotal,
    this.taxTotal,
    this.delivery,
    this.billNo,
    required this.status,
    required this.message,
  });
}
