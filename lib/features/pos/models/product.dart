import 'json_utils.dart';

/// A catalog product, parsed from `GET /pos/products` — the same dedicated
/// POS endpoint (`PosController::products`) the web POS terminal's
/// `productCatalog` memo consumes, already server-filtered to active items
/// and pre-joined with tax rate / stock, unlike the paginated admin CRUD
/// listing (`/admin/products`).
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

  /// `GET /pos/products` row shape (`PosController::products`): tax rate and
  /// selling price are already flattened server-side, unlike the nested
  /// `tax_code`/`uom` relation objects the admin CRUD listing returns.
  factory Product.fromPosJson(Map<String, dynamic> json) {
    return Product(
      id: asInt(json['id']),
      name: json['name'] as String,
      sku: json['sku'] as String?,
      hsCode: json['hs_code'] as String?,
      companyId: asInt(json['company_id']),
      category: _categoryLabel(json['category']),
      taxCodeId: asIntOrNull(json['tax_code_id']),
      taxRate: asDoubleOrNull(json['tax_rate']) ?? 13,
      price: asDoubleOrNull(json['price']) ?? 0,
      purchasePrice: asDoubleOrNull(json['purchase_price']) ?? 0,
      unit: json['unit'] as String? ?? '',
      type: json['type'] as String? ?? 'inventory',
      trackInventory: _asBool(json['track_inventory'], fallback: true),
      allowNegativeStock: _asBool(json['allow_negative_stock'], fallback: false),
      currentStock: asDoubleOrNull(json['current_stock']) ?? 0,
    );
  }
}
