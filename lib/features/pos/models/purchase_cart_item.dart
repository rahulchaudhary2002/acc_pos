import 'product.dart';

/// A line in the Buy/Purchase-Return cart. Purchases post `lines[]` to
/// `POST /admin/grns` + `POST /admin/purchase-bills` and returns post
/// `items[]` to `POST /pos/purchase-return` — the same endpoints and payload
/// shapes the web POS terminal uses.
class PurchaseCartItem {
  final Product product;
  double qty;
  double unitCost;

  PurchaseCartItem({required this.product, this.qty = 1, double? unitCost})
      : unitCost = unitCost ?? product.purchasePrice;

  double get lineTotal => qty * unitCost;
  double get lineTax => lineTotal * (product.taxRate / 100);

  /// GRN (stock receipt) line — mirrors `PosTerminal.jsx`'s submitPurchase
  /// normalizedLines (costs only, no tax).
  Map<String, dynamic> toGrnLineJson({int? locationId}) => {
        'product_id': product.id,
        'location_id': ?locationId,
        'qty': qty,
        'unit_cost': unitCost,
        'pcs_cost': unitCost,
        'total_amount': lineTotal,
        'uom_label': product.unit.isEmpty ? null : product.unit,
      };

  /// Purchase bill line — mirrors `PosTerminal.jsx`'s createPurchaseBill
  /// lines. The server recalculates tax from `tax_code_id`, matching the web.
  Map<String, dynamic> toBillLineJson({int? locationId}) => {
        'product_id': product.id,
        'location_id': ?locationId,
        'qty': qty,
        'rate': unitCost,
        'discount': 0,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
        'tax_amount': lineTax,
      };

  /// POS purchase-return item — mirrors `PosTerminal.jsx`'s
  /// submitPurchaseReturn items.
  Map<String, dynamic> toPosReturnJson() => {
        'product_id': product.id,
        'qty': qty,
        'rate': unitCost,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
      };
}
