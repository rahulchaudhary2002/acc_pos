import '../../../core/network/api_client.dart';
import '../models/breakdown_row.dart';
import '../models/company.dart';
import '../models/fiscal_year.dart';
import '../models/inventory_location.dart';
import '../models/outlet.dart';
import '../models/party.dart';
import '../models/product.dart';
import '../models/purchase_cart_item.dart';
import '../models/report_metric.dart';
import '../models/sale_cart_item.dart';
import '../models/tax_code.dart';
import '../models/transaction_result.dart';
import '../models/transaction_summary.dart';

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

/// Talks to every `/api/pos/*` endpoint (Sanctum bearer, see PosController.php).
class PosService {
  final ApiClient _client;

  PosService(this._client);

  Future<PosConfig> fetchConfig() async {
    final response = await _client.get('/pos/config');
    final data = response['data'] as Map<String, dynamic>;
    return PosConfig(
      companies: (data['companies'] as List).map((e) => Company.fromJson(e)).toList(),
      outlets: (data['outlets'] as List).map((e) => Outlet.fromJson(e)).toList(),
      fiscalYears: (data['fiscal_years'] as List).map((e) => FiscalYear.fromJson(e)).toList(),
      locations: (data['locations'] as List).map((e) => InventoryLocation.fromJson(e)).toList(),
      taxCodes: (data['tax_codes'] as List).map((e) => TaxCode.fromJson(e)).toList(),
    );
  }

  Future<List<Product>> fetchProducts({int? companyId, int? outletId, int? locationId}) async {
    final response = await _client.get('/pos/products', query: {
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (locationId != null) 'location_id': locationId,
    });
    return (response['data'] as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Party>> fetchCustomers({int? companyId}) async {
    final response = await _client.get('/pos/customers', query: {
      if (companyId != null) 'company_id': companyId,
    });
    return (response['data'] as List).map((e) => Party.fromJson(e)).toList();
  }

  Future<List<Party>> fetchSuppliers({int? companyId}) async {
    final response = await _client.get('/pos/suppliers', query: {
      if (companyId != null) 'company_id': companyId,
    });
    return (response['data'] as List).map((e) => Party.fromJson(e)).toList();
  }

  Future<List<Party>> fetchDistributors({int? companyId}) async {
    final response = await _client.get('/pos/distributors', query: {
      if (companyId != null) 'company_id': companyId,
    });
    return (response['data'] as List).map((e) => Party.fromJson(e)).toList();
  }

  Future<Party> createCustomer({
    required int companyId,
    required String name,
    String? mobileNo,
    String? address,
    String? panVatNo,
  }) async {
    final response = await _client.post('/pos/customers', data: {
      'company_id': companyId,
      'name': name,
      if (mobileNo != null && mobileNo.isNotEmpty) 'mobile_no': mobileNo,
      if (address != null && address.isNotEmpty) 'address': address,
      if (panVatNo != null && panVatNo.isNotEmpty) 'pan_vat_no': panVatNo,
    });
    return Party.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TransactionResult> sell({
    required int companyId,
    required int outletId,
    int? locationId,
    required String saleType,
    int? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? customerVatNumber,
    double deliveryCharge = 0,
    String? paymentMode,
    String? paymentReference,
    String? paymentNote,
    required List<SaleCartItem> items,
  }) async {
    final response = await _client.post('/pos/sell', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      if (locationId != null) 'location_id': locationId,
      'sale_type': saleType,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null && customerName.isNotEmpty) 'customer_name': customerName,
      if (customerPhone != null && customerPhone.isNotEmpty) 'customer_phone': customerPhone,
      if (customerAddress != null && customerAddress.isNotEmpty) 'customer_address': customerAddress,
      if (customerVatNumber != null && customerVatNumber.isNotEmpty) 'customer_vat_number': customerVatNumber,
      'delivery_charge': deliveryCharge,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (paymentReference != null && paymentReference.isNotEmpty) 'payment_reference': paymentReference,
      if (paymentNote != null && paymentNote.isNotEmpty) 'payment_note': paymentNote,
      'items': items.map((e) => e.toJson()).toList(),
    });
    return TransactionResult.fromSellJson(response);
  }

  Future<TransactionResult> buy({
    required int companyId,
    required int outletId,
    int? locationId,
    int? vendorId,
    String? supplierName,
    String? invoiceNumber,
    required List<PurchaseCartItem> items,
  }) async {
    final response = await _client.post('/pos/buy', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      if (locationId != null) 'location_id': locationId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (supplierName != null && supplierName.isNotEmpty) 'supplier_name': supplierName,
      if (invoiceNumber != null && invoiceNumber.isNotEmpty) 'invoice_number': invoiceNumber,
      'items': items.map((e) => e.toBuyJson()).toList(),
    });
    return TransactionResult.fromBuyJson(response);
  }

  Future<TransactionResult> sellReturn({
    required int companyId,
    required int outletId,
    int? locationId,
    int? customerId,
    int? referenceInvoiceId,
    required List<SaleCartItem> items,
  }) async {
    final response = await _client.post('/pos/sell-return', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      if (locationId != null) 'location_id': locationId,
      if (customerId != null) 'customer_id': customerId,
      if (referenceInvoiceId != null) 'reference_invoice_id': referenceInvoiceId,
      'items': items.map((e) => e.toJson()).toList(),
    });
    return TransactionResult.fromReturnJson(response);
  }

  Future<TransactionResult> purchaseReturn({
    required int companyId,
    required int outletId,
    int? locationId,
    required int vendorId,
    int? referenceGrnId,
    required List<PurchaseCartItem> items,
  }) async {
    final response = await _client.post('/pos/purchase-return', data: {
      'company_id': companyId,
      'outlet_id': outletId,
      if (locationId != null) 'location_id': locationId,
      'vendor_id': vendorId,
      if (referenceGrnId != null) 'reference_grn_id': referenceGrnId,
      'items': items.map((e) => e.toReturnJson()).toList(),
    });
    return TransactionResult.fromReturnJson(response);
  }

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

  Future<List<BreakdownRow>> fetchStoreWiseReport({int? companyId, int? outletId}) async {
    final response = await _client.get('/pos/reports/store-wise', query: {
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  Future<List<BreakdownRow>> fetchVendorWiseReport({int? companyId}) async {
    final response = await _client.get('/pos/reports/vendor-wise', query: {
      if (companyId != null) 'company_id': companyId,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  Future<List<BreakdownRow>> fetchCustomerWiseReport({int? companyId, int? outletId}) async {
    final response = await _client.get('/pos/reports/customer-wise', query: {
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
    });
    return (response['data'] as List).map((e) => BreakdownRow.fromJson(e)).toList();
  }

  Future<List<TransactionSummary>> fetchSalesList({int? companyId, int? outletId, String? search}) async {
    final response = await _client.get('/pos/sales-list', query: {
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (response['data'] as List).map((e) => TransactionSummary.fromSaleJson(e)).toList();
  }

  Future<List<TransactionSummary>> fetchPurchasesList({int? companyId, int? outletId, String? search}) async {
    final response = await _client.get('/pos/purchases-list', query: {
      if (companyId != null) 'company_id': companyId,
      if (outletId != null) 'outlet_id': outletId,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (response['data'] as List).map((e) => TransactionSummary.fromPurchaseJson(e)).toList();
  }
}
