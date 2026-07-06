/// A row from `GET /pos/reports/payment-modes` — sales split by payment mode.
class PaymentModeStat {
  final String mode;
  final double total;
  final int count;

  PaymentModeStat({required this.mode, required this.total, required this.count});

  factory PaymentModeStat.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());
    int asInt(dynamic v) => v == null ? 0 : int.parse(v.toString());
    return PaymentModeStat(
      mode: json['payment_mode'] as String? ?? 'unknown',
      total: asDouble(json['total']),
      count: asInt(json['count']),
    );
  }
}
