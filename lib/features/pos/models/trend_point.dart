/// One day of `GET /pos/reports/daily-trend` — `{date, total_sales, total_purchases}`.
class TrendPoint {
  final String date;
  final double totalSales;
  final double totalPurchases;

  TrendPoint({required this.date, required this.totalSales, required this.totalPurchases});

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());
    return TrendPoint(
      date: json['date'] as String,
      totalSales: asDouble(json['total_sales']),
      totalPurchases: asDouble(json['total_purchases']),
    );
  }
}
