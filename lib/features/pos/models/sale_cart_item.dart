import 'product.dart';

/// A line in the Sell/Sell-Return cart. Sales post `lines[]` to
/// `POST /admin/sales-invoices` and returns post `items[]` to
/// `POST /pos/sell-return` — the same two endpoints and payload shapes the
/// web POS terminal uses.
class SaleCartItem {
  final Product product;
  double qty;
  double rate;

  SaleCartItem({required this.product, this.qty = 1, double? rate})
      : rate = rate ?? product.price;

  double get taxRate => product.taxRate;
  double get lineSubtotal => qty * rate;

  /// Unrounded, like the web's `sellTotals`/`sellReturnTotals` tax terms
  /// (`rate * qty * taxRate / 100`) — the server rounds per line when it
  /// stores the invoice, so client totals must not round early either.
  double get taxAmount => lineSubtotal * taxRate / 100;
  double get lineTotal => lineSubtotal + taxAmount;

  /// Admin invoice line — mirrors `PosTerminal.jsx`'s submitSale lines.
  /// The server recalculates tax from `tax_code_id` (falling back to
  /// `tax_rate`), exactly as it does for web submissions.
  Map<String, dynamic> toLineJson({int? locationId}) => {
        'product_id': product.id,
        'location_id': ?locationId,
        'qty': qty,
        'rate': rate,
        'discount': 0,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
        'tax_amount': qty * rate * product.taxRate / 100,
      };

  /// POS sell-return item — mirrors `PosTerminal.jsx`'s submitSalesReturn items.
  Map<String, dynamic> toPosReturnJson() => {
        'product_id': product.id,
        'qty': qty,
        'rate': rate,
        'tax_code_id': product.taxCodeId,
        'tax_rate': product.taxRate,
      };
}
