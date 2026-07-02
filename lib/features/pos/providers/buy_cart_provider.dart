import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/purchase_cart_item.dart';

/// Buy-mode cart: mirrors the "Purchase Summary" panel in `PosTerminal.jsx`.
class BuyCartProvider extends ChangeNotifier {
  final List<PurchaseCartItem> items = [];

  double get netTotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;

  void addProduct(Product product) {
    final existingIndex = items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex != -1) {
      items[existingIndex].qty += 1;
    } else {
      items.add(PurchaseCartItem(product: product));
    }
    notifyListeners();
  }

  void updateQty(int index, double qty) {
    if (qty <= 0) return;
    items[index].qty = qty;
    notifyListeners();
  }

  void incrementQty(int index) {
    items[index].qty += 1;
    notifyListeners();
  }

  void decrementQty(int index) {
    if (items[index].qty > 1) {
      items[index].qty -= 1;
      notifyListeners();
    }
  }

  void updateUnitCost(int index, double unitCost) {
    items[index].unitCost = unitCost;
    notifyListeners();
  }

  void removeAt(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}
