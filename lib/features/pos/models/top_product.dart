/// A row from `GET /pos/reports/top-products` — best-selling products by revenue.
class TopProduct {
  final int productId;
  final String name;
  final String unit;
  final double qty;
  final double revenue;

  TopProduct({required this.productId, required this.name, required this.unit, required this.qty, required this.revenue});

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());
    int asInt(dynamic v) => v == null ? 0 : int.parse(v.toString());
    return TopProduct(
      productId: asInt(json['product_id']),
      name: json['product_name'] as String? ?? '-',
      unit: json['unit'] as String? ?? '',
      qty: asDouble(json['total_qty']),
      revenue: asDouble(json['total_revenue']),
    );
  }
}
