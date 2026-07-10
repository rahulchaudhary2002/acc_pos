import 'product.dart';

/// A line in the Buy/Purchase-Return cart — mirrors `items[]` in
/// `POST /pos/buy` and `POST /pos/purchase-return`.
class PurchaseCartItem {
  final Product product;
  double qty;
  double unitCost;

  PurchaseCartItem({required this.product, this.qty = 1, double? unitCost})
      : unitCost = unitCost ?? product.purchasePrice;

  double get lineTotal => qty * unitCost;

  Map<String, dynamic> toBuyJson() => {
        'product_id': product.id,
        'qty': qty,
        'unit_cost': unitCost,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
      };

  /// Purchase-return items additionally carry tax fields.
  Map<String, dynamic> toReturnJson() => {
        'product_id': product.id,
        'qty': qty,
        'rate': unitCost,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
      };
}
