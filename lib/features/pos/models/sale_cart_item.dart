import 'product.dart';

/// A line in the Sell/Sell-Return cart — mirrors `items[]` in
/// `POST /pos/sell` and `POST /pos/sell-return`.
class SaleCartItem {
  final Product product;
  double qty;
  double rate;

  SaleCartItem({required this.product, this.qty = 1, double? rate})
      : rate = rate ?? product.price;

  double get taxRate => product.taxRate;
  double get lineSubtotal => qty * rate;
  double get taxAmount => double.parse((lineSubtotal * taxRate / 100).toStringAsFixed(4));
  double get lineTotal => lineSubtotal + taxAmount;

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'qty': qty,
        'rate': rate,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
      };
}
