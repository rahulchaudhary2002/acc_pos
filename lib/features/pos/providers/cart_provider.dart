import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/sale_cart_item.dart';

/// Sell-mode cart: mirrors the "Current Sale" panel in `PosTerminal.jsx`
/// (add/remove products, qty stepper, editable rate, delivery charge, totals).
class CartProvider extends ChangeNotifier {
  final List<SaleCartItem> items = [];
  String saleType = 'cash'; // 'cash' | 'customer'
  double deliveryCharge = 0;

  /// Payment Type — 'cash' | 'credit' | 'online'. 'credit' only applies to
  /// customer sales; switching saleType back to 'cash' resets this to 'cash'.
  String paymentMode = 'cash';
  String remarks = '';
  String paymentReference = '';
  String paymentNote = '';

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineSubtotal);
  double get taxTotal => items.fold(0, (sum, i) => sum + i.taxAmount);
  double get grandTotal => subtotal + taxTotal + deliveryCharge;
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;

  void setSaleType(String type) {
    saleType = type;
    if (type == 'cash' && paymentMode == 'credit') paymentMode = 'cash';
    // Mirrors PosTerminal.jsx's changeSaleType: a customer sale defaults to
    // credit payment rather than carrying over whatever cash-sale mode was set.
    if (type == 'customer' && paymentMode == 'cash') paymentMode = 'credit';
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    paymentMode = mode;
    // Mirrors PosTerminal.jsx's changeSalePaymentMode: picking credit payment
    // forces the sale into customer mode (credit isn't valid for cash sales).
    if (mode == 'credit') saleType = 'customer';
    notifyListeners();
  }

  void setRemarks(String value) {
    remarks = value;
  }

  void setPaymentReference(String value) {
    paymentReference = value;
  }

  void setPaymentNote(String value) {
    paymentNote = value;
  }

  void setDeliveryCharge(double value) {
    deliveryCharge = value;
    notifyListeners();
  }

  /// Sellable cap for a product's cart qty, or null when unlimited (services
  /// and untracked items only). Mirrors PosTerminal.jsx's
  /// `isTrackedInventoryItem` check, which caps at `current_stock` for any
  /// tracked item regardless of `allow_negative_stock` — that flag only
  /// controls whether the *server* accepts an oversell, not the client cap.
  double? _maxQty(Product product) {
    if (product.isService || !product.trackInventory) return null;
    return product.currentStock;
  }

  void addProduct(Product product) {
    final existingIndex = items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex != -1) {
      final item = items[existingIndex];
      final maxQty = _maxQty(item.product);
      if (maxQty == null || item.qty < maxQty) {
        item.qty += 1;
      }
    } else {
      items.add(SaleCartItem(product: product));
    }
    notifyListeners();
  }

  void updateQty(int index, double qty) {
    if (qty <= 0) return;
    final maxQty = _maxQty(items[index].product);
    items[index].qty = (maxQty != null && qty > maxQty) ? maxQty : qty;
    notifyListeners();
  }

  void incrementQty(int index) {
    final maxQty = _maxQty(items[index].product);
    if (maxQty == null || items[index].qty < maxQty) {
      items[index].qty += 1;
    }
    notifyListeners();
  }

  void decrementQty(int index) {
    if (items[index].qty > 1) {
      items[index].qty -= 1;
      notifyListeners();
    }
  }

  void updateRate(int index, double rate) {
    items[index].rate = rate;
    notifyListeners();
  }

  void removeAt(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    items.clear();
    deliveryCharge = 0;
    paymentMode = 'cash';
    remarks = '';
    paymentReference = '';
    paymentNote = '';
    notifyListeners();
  }
}
