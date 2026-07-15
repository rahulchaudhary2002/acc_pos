import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/breakdown_row.dart';
import '../models/company.dart';
import '../models/fiscal_year.dart';
import '../models/inventory_location.dart';
import '../models/json_utils.dart';
import '../models/outlet.dart';
import '../models/party.dart';
import '../models/product.dart';
import '../models/product_price.dart';
import '../models/purchase_cart_item.dart';
import '../models/report_metric.dart';
import '../models/sale_cart_item.dart';
import '../models/payment_mode_stat.dart';
import '../models/tax_code.dart';
import '../models/top_product.dart';
import '../models/transaction_result.dart';
import '../models/transaction_summary.dart';
import '../models/trend_point.dart';

class PosConfig {
  final List<Company> companies;
  final List<Outlet> outlets;
  final List<FiscalYear> fiscalYears;
  final List<InventoryLocation> locations;
  final List<TaxCode> taxCodes;

  PosConfig({
    required this.companies,
    required this.outlets,
    required this.fiscalYears,
    required this.locations,
    required this.taxCodes,
  });
}

/// Mirrors the web POS terminal (`PosTerminal.jsx`) call-for-call so both
/// clients read and write through identical endpoints and payloads:
/// - reference data / catalog / parties / history via `/api/admin/*` listings,
/// - sales via `/admin/sales-invoices` create → approve → post,
/// - purchases via `/admin/grns` create → post + linked `/admin/purchase-bills`
///   create → approve → post,
/// - returns via `POST /pos/sell-return` / `POST /pos/purchase-return`,
/// - reports via `GET /pos/reports` (both clients share it).
class PosService {
  final ApiClient _client;

  PosService(this._client);

  String _today() => DateTime.now().toIso8601String().substring(0, 10);

  /// Web's `makeDocumentNo(prefix)`: prefix + first 14 digits of the ISO
  /// timestamp (yyyyMMddHHmmss).
  String _makeDocumentNo(String prefix) {
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(RegExp(r'[^0-9]'), '')
        .substring(0, 14);
    return '$prefix-$stamp';
  }

  List<Map<String, dynamic>> _listData(Map<String, dynamic> response) {
    final rows = response['data'] as List? ?? const [];
    return rows.map((row) => row as Map<String, dynamic>).toList();
  }

  // ── Reference data ────────────────────────────────────────────────────

  /// Same bootstrap listings the web POS terminal dispatches on mount.
  Future<PosConfig> fetchConfig() async {
    final responses = await Future.wait([
      _client.get('/admin/companies', query: {'per_page': 1000}),
      _client.get('/admin/outlets', query: {'per_page': 1000}),
      _client.get('/admin/fiscal-years', query: {'per_page': 1000}),
      _client.get('/admin/inventory-locations', query: {'per_page': 1000}),
      _client.get('/admin/tax-codes', query: {'per_page': 1000}),
    ]);

    return PosConfig(
      companies: _listData(responses[0]).map(Company.fromJson).toList(),
      outlets: _listData(responses[1]).map(Outlet.fromJson).toList(),
      fiscalYears: _listData(responses[2]).map(FiscalYear.fromJson).toList(),
      locations: _listData(responses[3]).map(InventoryLocation.fromJson).toList(),
      taxCodes: _listData(responses[4]).map(TaxCode.fromJson).toList(),
    );
  }

  /// Catalog = `/admin/products?pos_context=true` merged with
  /// `/admin/product-prices` using the web's 4-tier price fallback
  /// (outlet+retail → any+retail → outlet+any → any+any → product sale price).
  Future<List<Product>> fetchProducts({int? companyId, int? outletId, int? locationId}) async {
    final responses = await Future.wait([
      _client.get('/admin/products', query: {
        'per_page': 1000,
        if (companyId != null) 'company_id': companyId,
        if (outletId != null) 'outlet_id': outletId,
        if (locationId != null) 'location_id': locationId,
        'pos_context': true,
      }),
      if (companyId != null)
        _client.get('/admin/product-prices', query: {
          'company_id': companyId,
          'per_page': 1000,
          'sort_by': 'effective_from',
          'sort_dir': 'desc',
        }),
    ]);

    final priceRows = responses.length > 1
        ? _listData(responses[1]).map(ProductPrice.fromJson).toList()
        : <ProductPrice>[];

    // Latest price wins per tier — same sort the web applies before its
    // first-hit-wins maps: effective_from desc, then created_at desc.
    priceRows.sort((a, b) {
      final effective = b.effectiveFrom.compareTo(a.effectiveFrom);
      if (effective != 0) return effective;
      return b.createdAt.compareTo(a.createdAt);
    });

    final outletRetail = <int, double>{};
    final fallbackRetail = <int, double>{};
    final outletAny = <int, double>{};
    final fallbackAny = <int, double>{};

    for (final price in priceRows) {
      fallbackAny.putIfAbsent(price.productId, () => price.sellingPrice);
      final matchesOutlet = outletId != null && price.outletId == outletId;
      if (matchesOutlet) {
        outletAny.putIfAbsent(price.productId, () => price.sellingPrice);
      }
      if (price.priceType.toLowerCase() == 'retail') {
        fallbackRetail.putIfAbsent(price.productId, () => price.sellingPrice);
        if (matchesOutlet) {
          outletRetail.putIfAbsent(price.productId, () => price.sellingPrice);
        }
      }
    }

    return _listData(responses[0])
        .map((json) {
          final id = asInt(json['id']);
          final price = outletRetail[id] ??
              fallbackRetail[id] ??
              outletAny[id] ??
              fallbackAny[id] ??
              asDoubleOrNull(json['sale_price']) ??
              asDoubleOrNull(json['selling_price']) ??
              0;
          return Product.fromAdminJson(json, price: price);
        })
        .where((product) => product.isActive)
        .toList();
  }

  // ── Parties ───────────────────────────────────────────────────────────

  /// One `/admin/parties` listing per company, filtered client-side —
  /// exactly how the web derives customerOptions/vendorOptions.
  Future<List<Party>> _fetchParties({int? companyId}) async {
    final response = await _client.get('/admin/parties', query: {
      if (companyId != null) 'company_id': companyId,
      'per_page': 1000,
    });
    return _listData(response).map(Party.fromJson).toList();
  }

  /// Web `customerOptions`: type customer | both | walk-in.
  Future<List<Party>> fetchCustomers({int? companyId}) async {
    final parties = await _fetchParties(companyId: companyId);
    const types = {'customer', 'both', 'walk-in'};
    return parties.where((p) => types.contains((p.type ?? '').toLowerCase())).toList();
  }

  /// Web `vendorOptions`: type vendor | both AND is_distributor.
  Future<List<Party>> fetchSuppliers({int? companyId}) async {
    final parties = await _fetchParties(companyId: companyId);
    const types = {'vendor', 'both'};
    return parties
        .where((p) => types.contains((p.type ?? '').toLowerCase()) && p.isDistributor)
        .toList();
  }

  /// The web POS has a single vendor list (`vendorOptions`) — distributors
  /// and suppliers are the same set.
  Future<List<Party>> fetchDistributors({int? companyId}) => fetchSuppliers(companyId: companyId);

  Future<Party> _createParty({
    required int companyId,
    required String type,
    required String name,
    String? phone,
    String? address,
    String? panVatNo,
    bool? isDistributor,
  }) async {
    final response = await _client.post('/admin/parties', data: {
      'company_id': companyId,
      'type': type,
      'name': name,
      // The web sends the same value as both phone and mobile_no.
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (phone != null && phone.isNotEmpty) 'mobile_no': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      if (panVatNo != null && panVatNo.isNotEmpty) 'pan_vat_no': panVatNo,
      'is_distributor': ?isDistributor,
    });
    return Party.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Party> createCustomer({
    required int companyId,
    required String name,
    String? mobileNo,
    String? address,
    String? panVatNo,
  }) {
    return _createParty(
      companyId: companyId,
      type: 'customer',
      name: name,
      phone: mobileNo,
      address: address,
      panVatNo: panVatNo,
    );
  }

  /// Web `ensureCustomerForSale` for cash sales: use any existing walk-in
  /// party, else silently create "Walk-in Customer".
  Future<int> _resolveWalkInCustomerId(int companyId) async {
    final parties = await _fetchParties(companyId: companyId);
    for (final party in parties) {
      if ((party.type ?? '').toLowerCase() == 'walk-in') return party.id;
    }
    final created = await _createParty(
      companyId: companyId,
      type: 'walk-in',
      name: 'Walk-in Customer',
    );
    return created.id;
  }

  /// Exact-name vendor lookup on the same listing. Listing also materialises
  /// head-office vendor clones for this company (PartyController@index),
  /// which makes the created-vendor lookup in [buy] reliable.
  Future<Party?> _findVendorByName({required int companyId, required String name}) async {
    final parties = await _fetchParties(companyId: companyId);
    final wanted = name.trim().toLowerCase();
    for (final party in parties) {
      if (party.name.trim().toLowerCase() == wanted) return party;
    }
    return null;
  }

  // ── Documents ─────────────────────────────────────────────────────────

  /// Runs the web admin approve → post lifecycle on a stored draft. If either
  /// step fails the document still exists server-side as a draft, so say so
  /// instead of surfacing a generic error.
  Future<void> _approveAndPost(String resource, int id, String documentLabel) async {
    try {
      await _client.post('/admin/$resource/$id/approve');
      await _client.post('/admin/$resource/$id/post');
    } on ApiException catch (e) {
      throw ApiException(
        message: '$documentLabel was saved as a draft but could not be posted: ${e.message}',
        fieldErrors: e.fieldErrors,
        statusCode: e.statusCode,
      );
    }
  }

  /// Mirrors the web POS `submitSale`: resolve the customer, then
  /// `POST /admin/sales-invoices` → approve → post.
  Future<TransactionResult> sell({
    required int companyId,
    required int outletId,
    int? locationId,
    int? fiscalYearId,
    required String saleType,
    int? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerVatNumber,
    String? salesperson,
    double deliveryCharge = 0,
    String? paymentMode,
    String? paymentReference,
    String? paymentNote,
    required List<SaleCartItem> items,
  }) async {
    var resolvedCustomerId = customerId;
    if (resolvedCustomerId == null && customerName != null && customerName.isNotEmpty) {
      final party = await _createParty(
        companyId: companyId,
        type: 'customer',
        name: customerName,
        phone: customerPhone,
        address: customerAddress,
        panVatNo: customerVatNumber,
      );
      resolvedCustomerId = party.id;
    }
    resolvedCustomerId ??= await _resolveWalkInCustomerId(companyId);

    final response = await _client.post('/admin/sales-invoices', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      'fiscal_year_id': ?fiscalYearId,
      'invoice_date': _today(),
      'customer_id': resolvedCustomerId,
      if (salesperson != null && salesperson.isNotEmpty) 'salesperson': salesperson,
      'payment_mode': paymentMode ?? (saleType == 'cash' ? 'cash' : 'credit'),
      if (paymentReference != null && paymentReference.isNotEmpty) 'payment_reference': paymentReference,
      if (paymentNote != null && paymentNote.isNotEmpty) 'payment_note': paymentNote,
      if (customerAddress != null && customerAddress.isNotEmpty) 'shipping_address': customerAddress,
      'discount': 0,
      'delivery_charge': deliveryCharge,
      'lines': items.map((e) => e.toLineJson(locationId: locationId)).toList(),
    });

    final invoice = response['data'] as Map<String, dynamic>;
    final invoiceId = asInt(invoice['id']);
    final invoiceNo = invoice['invoice_no'] as String? ?? 'INV-$invoiceId';
    await _approveAndPost('sales-invoices', invoiceId, 'Invoice $invoiceNo');

    return TransactionResult(
      documentNo: invoiceNo,
      documentId: invoiceId,
      total: asDouble(invoice['grand_total']),
      subtotal: asDoubleOrNull(invoice['subtotal']),
      taxTotal: asDoubleOrNull(invoice['tax_total']),
      delivery: asDoubleOrNull(invoice['delivery_charge']),
      status: 'posted',
      message: 'Sale completed successfully.',
    );
  }

  /// Mirrors the web POS `submitPurchase`: `POST /admin/grns` → post, then a
  /// linked `POST /admin/purchase-bills` → approve → post (the bill skips
  /// stock because the GRN already posted it).
  Future<TransactionResult> buy({
    required int companyId,
    required int outletId,
    int? locationId,
    int? fiscalYearId,
    int? vendorId,
    String? supplierName,
    String? invoiceNumber,
    String? transactionDate,
    required List<PurchaseCartItem> items,
  }) async {
    var resolvedVendorId = vendorId;
    if (resolvedVendorId == null && supplierName != null && supplierName.isNotEmpty) {
      final existing = await _findVendorByName(companyId: companyId, name: supplierName);
      if (existing != null) {
        resolvedVendorId = existing.id;
      } else {
        // fetchSuppliers() (mirroring web's vendorOptions) only surfaces
        // is_distributor parties, so a vendor auto-created here must be
        // flagged as one — otherwise it posts fine but silently never shows
        // up in the vendor picker again, even after the post-purchase reload.
        final created = await _createParty(
          companyId: companyId,
          type: 'vendor',
          name: supplierName,
          isDistributor: true,
        );
        // New vendors are re-homed to the head company and cloned per company
        // (PartyController@store) — transactions may only reference this
        // company's clone, so look the vendor up again after creating it.
        final localClone = await _findVendorByName(companyId: companyId, name: supplierName);
        resolvedVendorId = (localClone ?? created).id;
      }
    }
    if (resolvedVendorId == null) {
      throw ApiException(message: 'Supplier/vendor is required.');
    }

    final date = transactionDate ?? _today();
    final hasInvoiceNo = invoiceNumber != null && invoiceNumber.isNotEmpty;
    final grnNo = hasInvoiceNo ? invoiceNumber : _makeDocumentNo('GRN-POS');
    final billNo = hasInvoiceNo ? invoiceNumber : _makeDocumentNo('PB-POS');
    final subtotal = items.fold<double>(0, (sum, e) => sum + e.lineTotal);
    final taxTotal = items.fold<double>(0, (sum, e) => sum + e.lineTax);

    final grnResponse = await _client.post('/admin/grns', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      'fiscal_year_id': ?fiscalYearId,
      'vendor_id': resolvedVendorId,
      'grn_no': grnNo,
      'grn_date': date,
      'subtotal': subtotal,
      'taxable_amount': subtotal,
      'non_taxable_amount': 0,
      'net_purchase': subtotal,
      'vat_amount': taxTotal,
      'net_total': subtotal + taxTotal,
      'lines': items.map((e) => e.toGrnLineJson(locationId: locationId)).toList(),
    });

    final grn = grnResponse['data'] as Map<String, dynamic>;
    final grnId = asInt(grn['id']);
    final grnDocumentNo = grn['grn_no'] as String? ?? grnNo;

    try {
      await _client.post('/admin/grns/$grnId/post');
    } on ApiException catch (e) {
      throw ApiException(
        message: 'GRN $grnDocumentNo was saved but could not be posted: ${e.message}',
        fieldErrors: e.fieldErrors,
        statusCode: e.statusCode,
      );
    }

    final billResponse = await _client.post('/admin/purchase-bills', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      'fiscal_year_id': ?fiscalYearId,
      'vendor_id': resolvedVendorId,
      'grn_id': grnId,
      'bill_no': billNo,
      if (hasInvoiceNo) 'vendor_invoice_no': invoiceNumber,
      'bill_date': date,
      'discount': 0,
      'lines': items.map((e) => e.toBillLineJson(locationId: locationId)).toList(),
    });

    final bill = billResponse['data'] as Map<String, dynamic>;
    final billId = asInt(bill['id']);
    final billDocumentNo = bill['bill_no'] as String? ?? billNo;
    await _approveAndPost('purchase-bills', billId, 'Purchase bill $billDocumentNo');

    return TransactionResult(
      documentNo: grnDocumentNo,
      documentId: grnId,
      total: asDoubleOrNull(bill['grand_total']) ?? (subtotal + taxTotal),
      subtotal: asDoubleOrNull(bill['subtotal']),
      taxTotal: asDoubleOrNull(bill['tax_total']),
      billNo: billDocumentNo,
      status: 'posted',
      message: 'Purchase recorded successfully.',
    );
  }

  /// Mirrors the web POS `submitSalesReturn` — same `POST /pos/sell-return`
  /// endpoint and payload the web uses.
  Future<TransactionResult> sellReturn({
    required int companyId,
    required int outletId,
    int? locationId,
    int? customerId,
    required List<SaleCartItem> items,
  }) async {
    final response = await _client.post('/pos/sell-return', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      'location_id': locationId,
      'customer_id': customerId,
      'return_date': _today(),
      'items': items.map((e) => e.toPosReturnJson()).toList(),
    });
    return _posReturnResult(response, 'Sales return completed successfully.');
  }

  /// Mirrors the web POS `submitPurchaseReturn` — same
  /// `POST /pos/purchase-return` endpoint and payload the web uses.
  Future<TransactionResult> purchaseReturn({
    required int companyId,
    required int outletId,
    int? locationId,
    required int vendorId,
    required List<PurchaseCartItem> items,
  }) async {
    final response = await _client.post('/pos/purchase-return', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      'location_id': locationId,
      'vendor_id': vendorId,
      'return_date': _today(),
      'items': items.map((e) => e.toPosReturnJson()).toList(),
    });
    return _posReturnResult(response, 'Purchase return completed successfully.');
  }

  TransactionResult _posReturnResult(Map<String, dynamic> response, String fallbackMessage) {
    final data = response['data'] as Map<String, dynamic>;
    return TransactionResult(
      documentNo: data['return_no'] as String? ?? '',
      documentId: asInt(data['return_id']),
      total: asDouble(data['grand_total']),
      subtotal: asDoubleOrNull(data['subtotal']),
      taxTotal: asDoubleOrNull(data['tax_total']),
      status: data['status'] as String? ?? 'posted',
      message: response['message'] as String? ?? fallbackMessage,
    );
  }

  // ── Reports (the web POS reads these same /pos endpoints) ─────────────

  Future<ReportMetrics> fetchReports({
    required String period,
    int? companyId,
    int? outletId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _client.get('/pos/reports', query: {
      'period': period,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return ReportMetrics.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<TrendPoint>> fetchReportTrend({
    required String period,
    int? companyId,
    int? outletId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _client.get('/pos/reports/daily-trend', query: {
      'period': period,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => TrendPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TopProduct>> fetchTopProducts({
    required String period,
    int? companyId,
    int? outletId,
    int limit = 10,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _client.get('/pos/reports/top-products', query: {
      'period': period,
      'limit': limit,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PaymentModeStat>> fetchPaymentModeBreakdown({
    required String period,
    int? companyId,
    int? outletId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _client.get('/pos/reports/payment-modes', query: {
      'period': period,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => PaymentModeStat.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BreakdownRow>> fetchStoreWiseReport({String? period, int? companyId, int? outletId, String? fromDate, String? toDate}) async {
    final response = await _client.get('/pos/reports/store-wise', query: {
      if (period != null) 'period': period,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  Future<List<BreakdownRow>> fetchVendorWiseReport({String? period, int? companyId, String? fromDate, String? toDate}) async {
    final response = await _client.get('/pos/reports/vendor-wise', query: {
      if (period != null) 'period': period,
      if (companyId != null) 'company_id': companyId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  Future<List<BreakdownRow>> fetchCustomerWiseReport({String? period, int? companyId, int? outletId, String? fromDate, String? toDate}) async {
    final response = await _client.get('/pos/reports/customer-wise', query: {
      if (period != null) 'period': period,
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  // ── History listings ──────────────────────────────────────────────────

  /// Web `getReportsRange`: resolve a period key to a from/to date pair.
  /// Returns null for lifetime (no date filter).
  ({String from, String to})? _rangeForPeriod(String? period, String? fromDate, String? toDate) {
    final now = DateTime.now();
    String iso(DateTime d) => d.toIso8601String().substring(0, 10);
    final today = iso(now);

    switch (period) {
      case 'today':
        return (from: today, to: today);
      case 'yesterday':
        final yesterday = iso(now.subtract(const Duration(days: 1)));
        return (from: yesterday, to: yesterday);
      case 'last_7_days':
        return (from: iso(now.subtract(const Duration(days: 6))), to: today);
      case 'last_30_days':
        return (from: iso(now.subtract(const Duration(days: 29))), to: today);
      case 'last_month':
        return (
          from: iso(DateTime(now.year, now.month - 1, 1)),
          to: iso(DateTime(now.year, now.month, 0)),
        );
      case 'custom':
        final from = fromDate ?? today;
        final to = toDate ?? fromDate ?? today;
        return from.compareTo(to) > 0 ? (from: to, to: from) : (from: from, to: to);
      case 'lifetime':
      case null:
        return null;
      case 'this_month':
      default:
        return (from: iso(DateTime(now.year, now.month, 1)), to: today);
    }
  }

  /// Posted invoices from `GET /admin/sales-invoices` — the same listing the
  /// web POS keeps loaded (`fetchSalesInvoices({status: 'posted'})`).
  Future<List<TransactionSummary>> fetchSalesList({String? period, int? companyId, int? outletId, String? search, String? fromDate, String? toDate}) async {
    final range = _rangeForPeriod(period, fromDate, toDate);
    final response = await _client.get('/admin/sales-invoices', query: {
      'per_page': 1000,
      'status': 'posted',
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (range != null) 'from_date': range.from,
      if (range != null) 'to_date': range.to,
    });
    return _listData(response).map(TransactionSummary.fromSaleJson).toList();
  }

  /// Posted bills from `GET /admin/purchase-bills` — the same listing the
  /// web POS keeps loaded (`fetchPurchaseBills`).
  Future<List<TransactionSummary>> fetchPurchasesList({String? period, int? companyId, int? outletId, String? search, String? fromDate, String? toDate}) async {
    final range = _rangeForPeriod(period, fromDate, toDate);
    final response = await _client.get('/admin/purchase-bills', query: {
      'per_page': 1000,
      'status': 'posted',
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (search != null && search.isNotEmpty) 'search': search,
      if (range != null) 'from_date': range.from,
      if (range != null) 'to_date': range.to,
    });
    return _listData(response).map(TransactionSummary.fromPurchaseJson).toList();
  }
}
