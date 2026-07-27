import 'json_utils.dart';

/// A row from `GET /admin/reports/stock-balance` — current stock position
/// for one product at one outlet/location.
class StockReportRow {
  final int id;
  final int productId;
  final String sku;
  final String productName;
  final String? categoryName;
  final String? unitCode;
  final int outletId;
  final String outletName;
  final int locationId;
  final String locationName;
  final double qty;
  final double avgCost;
  final double stockValue;
  final double? minStock;
  final double? maxStock;

  StockReportRow({
    required this.id,
    required this.productId,
    required this.sku,
    required this.productName,
    this.categoryName,
    this.unitCode,
    required this.outletId,
    required this.outletName,
    required this.locationId,
    required this.locationName,
    required this.qty,
    required this.avgCost,
    required this.stockValue,
    this.minStock,
    this.maxStock,
  });

  factory StockReportRow.fromJson(Map<String, dynamic> json) {
    return StockReportRow(
      id: asInt(json['id']),
      productId: asInt(json['product_id']),
      sku: json['sku'] as String? ?? '-',
      productName: json['product_name'] as String? ?? '-',
      categoryName: json['category_name'] as String?,
      unitCode: json['unit_code'] as String?,
      outletId: asInt(json['outlet_id']),
      outletName: json['outlet_name'] as String? ?? '-',
      locationId: asInt(json['location_id']),
      locationName: json['location_name'] as String? ?? '-',
      qty: asDoubleOrNull(json['qty']) ?? 0,
      avgCost: asDoubleOrNull(json['avg_cost']) ?? 0,
      stockValue: asDoubleOrNull(json['stock_value']) ?? 0,
      minStock: asDoubleOrNull(json['min_stock']),
      maxStock: asDoubleOrNull(json['max_stock']),
    );
  }
}
