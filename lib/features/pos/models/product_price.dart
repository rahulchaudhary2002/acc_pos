import 'json_utils.dart';

/// A row from `GET /admin/product-prices` — used to resolve each product's
/// selling price with the same 4-tier fallback the web POS terminal applies
/// client-side (outlet+retail → any-outlet+retail → outlet+any-type →
/// any-outlet+any-type).
class ProductPrice {
  final int productId;
  final int? outletId;
  final String priceType;
  final double sellingPrice;
  final String effectiveFrom;
  final String createdAt;

  ProductPrice({
    required this.productId,
    this.outletId,
    required this.priceType,
    required this.sellingPrice,
    required this.effectiveFrom,
    required this.createdAt,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      productId: asInt(json['product_id']),
      outletId: asIntOrNull(json['outlet_id']),
      priceType: (json['price_type'] as String?) ?? 'retail',
      sellingPrice: asDoubleOrNull(json['selling_price']) ?? 0,
      effectiveFrom: json['effective_from'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
