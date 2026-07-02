import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../models/party.dart';
import '../models/product.dart';
import '../services/pos_service.dart';

/// Loads and filters products/customers/suppliers for the active
/// company/outlet/location — shared by Sell, Buy, and both Return screens.
class PosDataProvider extends ChangeNotifier {
  final PosService _posService;

  PosDataProvider(this._posService);

  bool isLoadingProducts = false;
  bool isLoadingParties = false;
  String? errorMessage;

  List<Product> products = [];
  List<Party> customers = [];
  List<Party> suppliers = [];

  String searchQuery = '';
  // Mirrors PosTerminal.jsx's productTab state — 'products' | 'accessories' | 'services'.
  String categoryFilter = 'products';

  static const List<String> categories = ['products', 'accessories', 'services'];

  List<Product> get filteredProducts {
    // Matches visibleProducts in PosTerminal.jsx: filter by kind, but the
    // "products" tab falls back to every non-service item when that
    // classification yields nothing (e.g. no catalog data has been tagged
    // as a plain "product" yet) instead of showing an empty grid.
    var byTab = products.where((p) => p.kind == categoryFilter).toList();
    if (byTab.isEmpty && categoryFilter == 'products') {
      byTab = products.where((p) => p.kind != 'services').toList();
    }
    if (searchQuery.isEmpty) return byTab;
    final query = searchQuery.toLowerCase();
    return byTab.where((p) => p.name.toLowerCase().contains(query) || (p.sku?.toLowerCase().contains(query) ?? false)).toList();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    categoryFilter = category;
    notifyListeners();
  }

  Future<void> loadProducts({int? companyId, int? outletId, int? locationId}) async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await _posService.fetchProducts(
        companyId: companyId,
        outletId: outletId,
        locationId: locationId,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadParties({int? companyId}) async {
    isLoadingParties = true;
    notifyListeners();
    try {
      customers = await _posService.fetchCustomers(companyId: companyId);
      suppliers = await _posService.fetchSuppliers(companyId: companyId);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoadingParties = false;
      notifyListeners();
    }
  }

  void addCustomer(Party party) {
    customers = [...customers, party];
    notifyListeners();
  }

  /// Wipes cached products/customers/suppliers on logout — otherwise a
  /// different user logging in on the same device would briefly see the
  /// previous account's stock/party data until the next successful fetch.
  void reset() {
    products = [];
    customers = [];
    suppliers = [];
    searchQuery = '';
    categoryFilter = 'products';
    errorMessage = null;
    notifyListeners();
  }
}
