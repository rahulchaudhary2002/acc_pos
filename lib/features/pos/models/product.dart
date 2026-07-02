import 'json_utils.dart';

class Product {
  final int id;
  final String name;
  final String? sku;
  final String? hsCode;
  final int companyId;
  final String category;
  final int? taxCodeId;
  final double taxRate;
  final double price;
  final double purchasePrice;
  final String type;
  final bool trackInventory;
  final bool allowNegativeStock;
  final double currentStock;
  final bool outOfStock;

  Product({
    required this.id,
    required this.name,
    this.sku,
    this.hsCode,
    required this.companyId,
    required this.category,
    this.taxCodeId,
    required this.taxRate,
    required this.price,
    required this.purchasePrice,
    required this.type,
    required this.trackInventory,
    required this.allowNegativeStock,
    required this.currentStock,
    required this.outOfStock,
  });

  bool get isService => type.toLowerCase() == 'service';

  /// Mirrors `PosTerminal.jsx`'s client-side `kind` classification exactly
  /// (products/accessories/services tabs) — the server never groups by this,
  /// so both clients must derive it the same way from name/category/type.
  static final _serviceCategoryPattern = RegExp('service');
  static final _accessoryNamePattern = RegExp('accessor|regulator|hose|burner');
  static final _accessoryCategoryPattern = RegExp('accessor');

  String get kind {
    final categoryLabel = category.toLowerCase();
    final typeLabel = type.toLowerCase();
    if (typeLabel == 'service' || _serviceCategoryPattern.hasMatch(categoryLabel)) {
      return 'services';
    }
    final nameLabel = name.toLowerCase();
    if (_accessoryNamePattern.hasMatch(nameLabel) || _accessoryCategoryPattern.hasMatch(categoryLabel)) {
      return 'accessories';
    }
    return 'products';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: asInt(json['id']),
      name: json['name'] as String,
      sku: json['sku'] as String?,
      hsCode: json['hs_code'] as String?,
      companyId: asInt(json['company_id']),
      category: json['category'] as String? ?? 'Products',
      taxCodeId: asIntOrNull(json['tax_code_id']),
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 13,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? 'inventory',
      trackInventory: json['track_inventory'] == true,
      allowNegativeStock: json['allow_negative_stock'] == true,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
      outOfStock: json['out_of_stock'] == true,
    );
  }
}
