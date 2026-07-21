import 'json_utils.dart';

/// A catalog product, parsed from `GET /admin/products?pos_context=true` —
/// the same endpoint and row shape the web POS terminal consumes. Selling
/// price is the flat `products.selling_price` column returned on the row
/// (see `PosService.fetchProducts`), mirroring `PosTerminal.jsx`'s
/// `productCatalog` memo.
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
  final String unit;
  final String type;
  final bool trackInventory;
  final bool allowNegativeStock;
  final bool isActive;
  final double currentStock;

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
    this.unit = '',
    required this.type,
    required this.trackInventory,
    required this.allowNegativeStock,
    this.isActive = true,
    required this.currentStock,
  });

  bool get isService => type.toLowerCase() == 'service';

  /// Same disable rule the web POS applies to tracked items with no stock.
  bool get outOfStock =>
      !isService && trackInventory && !allowNegativeStock && currentStock <= 0;

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

  static bool _asBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    return value == 1 || value == '1' || value == 'true';
  }

  /// `category` can be a plain string column or a `{name}` relation object,
  /// same duality the web handles with `product.category?.name || product.category`.
  static String _categoryLabel(dynamic value) {
    if (value is Map<String, dynamic>) return value['name'] as String? ?? 'Products';
    if (value is String && value.isNotEmpty) return value;
    return 'Products';
  }

  factory Product.fromAdminJson(Map<String, dynamic> json, {required double price}) {
    final taxCode = json['tax_code'] as Map<String, dynamic>?;
    final uom = json['uom'] as Map<String, dynamic>?;
    return Product(
      id: asInt(json['id']),
      name: json['name'] as String,
      sku: json['sku'] as String?,
      hsCode: json['hs_code'] as String?,
      companyId: asInt(json['company_id']),
      category: _categoryLabel(json['category']),
      taxCodeId: asIntOrNull(json['tax_code_id']),
      // Same default the web's resolveTaxRate() applies when no tax code.
      taxRate: asDoubleOrNull(taxCode?['rate']) ?? 13,
      price: price,
      purchasePrice: asDoubleOrNull(json['purchase_price']) ?? 0,
      unit: uom?['code'] as String? ?? json['unit'] as String? ?? '',
      type: json['type'] as String? ?? 'inventory',
      trackInventory: _asBool(json['track_inventory'], fallback: true),
      allowNegativeStock: _asBool(json['allow_negative_stock'], fallback: false),
      isActive: _asBool(json['is_active'], fallback: true),
      currentStock: asDoubleOrNull(json['current_stock']) ?? 0,
    );
  }
}
