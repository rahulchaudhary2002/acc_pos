import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/company.dart';
import '../models/fiscal_year.dart';
import '../models/inventory_location.dart';
import '../models/outlet.dart';
import '../models/tax_code.dart';
import '../services/pos_service.dart';

/// Loads `/pos/config` once after login and holds the active
/// company/outlet/location selection used by every other POS screen.
class PosConfigProvider extends ChangeNotifier {
  final PosService _posService;
  final TokenStorage _tokenStorage;

  PosConfigProvider({required PosService posService, required TokenStorage tokenStorage})
      : _posService = posService,
        _tokenStorage = tokenStorage;

  bool isLoading = false;
  String? errorMessage;

  List<Company> companies = [];
  List<Outlet> outlets = [];
  List<FiscalYear> fiscalYears = [];
  List<InventoryLocation> locations = [];
  List<TaxCode> taxCodes = [];

  int? selectedCompanyId;
  int? selectedOutletId;
  int? selectedLocationId;
  int? selectedFiscalYearId;

  bool get needsCompanyPicker => companies.length > 1 && selectedCompanyId == null;
  bool get isReady => selectedCompanyId != null && selectedOutletId != null;

  List<Outlet> outletsForSelectedCompany() =>
      outlets.where((o) => o.companyId == selectedCompanyId).toList();

  List<InventoryLocation> locationsForSelectedOutlet() =>
      locations.where((l) => l.outletId == selectedOutletId).toList();

  List<FiscalYear> fiscalYearsForSelectedCompany() =>
      fiscalYears.where((f) => f.companyId == selectedCompanyId).toList();

  double taxRateFor(int? taxCodeId) {
    if (taxCodeId == null) return 13;
    final match = taxCodes.where((t) => t.id == taxCodeId);
    return match.isEmpty ? 13 : match.first.rate;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final config = await _posService.fetchConfig();
      companies = config.companies;
      outlets = config.outlets;
      fiscalYears = config.fiscalYears;
      locations = config.locations;
      taxCodes = config.taxCodes;

      final saved = await _tokenStorage.readSelection();
      if (companies.length == 1) {
        selectCompany(companies.first.id);
      } else if (saved['companyId'] != null &&
          companies.any((c) => c.id == saved['companyId'])) {
        selectCompany(saved['companyId']!, restoredOutletId: saved['outletId'], restoredLocationId: saved['locationId']);
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Mirrors `useWorkspaceContext.js`'s default-selection behavior: always
  // fall back to the first outlet/warehouse in the list rather than only
  // auto-selecting when there's exactly one. Requiring an exact match of 1
  // left multi-outlet companies with no selection at all on first launch,
  // which both blocked the POS screens (isReady stayed false) and meant the
  // app could end up pinned to a different outlet than the web app's
  // always-picks-first default — showing different stock for "the same"
  // product even though both hit the same database.
  void selectCompany(int companyId, {int? restoredOutletId, int? restoredLocationId}) {
    selectedCompanyId = companyId;
    final companyOutlets = outletsForSelectedCompany();
    if (restoredOutletId != null && companyOutlets.any((o) => o.id == restoredOutletId)) {
      selectOutlet(restoredOutletId, restoredLocationId: restoredLocationId);
    } else if (companyOutlets.isNotEmpty) {
      selectOutlet(companyOutlets.first.id);
    } else {
      selectedOutletId = null;
      selectedLocationId = null;
    }
    final companyFiscalYears = fiscalYearsForSelectedCompany();
    selectedFiscalYearId = companyFiscalYears.isEmpty
        ? null
        : companyFiscalYears.firstWhere((f) => f.isCurrent, orElse: () => companyFiscalYears.first).id;
    _tokenStorage.saveSelection(companyId: companyId);
    notifyListeners();
  }

  void selectFiscalYear(int fiscalYearId) {
    selectedFiscalYearId = fiscalYearId;
    notifyListeners();
  }

  void selectOutlet(int outletId, {int? restoredLocationId}) {
    selectedOutletId = outletId;
    final outletLocations = locationsForSelectedOutlet();
    if (restoredLocationId != null && outletLocations.any((l) => l.id == restoredLocationId)) {
      selectedLocationId = restoredLocationId;
    } else if (outletLocations.isNotEmpty) {
      selectedLocationId = outletLocations.first.id;
    } else {
      selectedLocationId = null;
    }
    _tokenStorage.saveSelection(outletId: outletId, locationId: selectedLocationId);
    notifyListeners();
  }

  void selectLocation(int locationId) {
    selectedLocationId = locationId;
    _tokenStorage.saveSelection(locationId: locationId);
    notifyListeners();
  }

  /// Wipes the cached company/outlet/warehouse config on logout — otherwise
  /// a different user logging in on the same device would briefly see the
  /// previous account's workspace until the next `load()` completes.
  void reset() {
    isLoading = false;
    errorMessage = null;
    companies = [];
    outlets = [];
    fiscalYears = [];
    locations = [];
    taxCodes = [];
    selectedCompanyId = null;
    selectedOutletId = null;
    selectedLocationId = null;
    selectedFiscalYearId = null;
    notifyListeners();
  }
}
