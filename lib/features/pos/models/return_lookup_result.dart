import 'json_utils.dart';

/// One line resolved from an original sales invoice / purchase bill, used to
/// pre-fill a return cart. `productId` is matched against the already-loaded
/// product catalog by the calling screen — this model only carries the raw
/// values the server returned for that line.
class ReturnLookupLine {
  final int productId;
  final double qty;
  final double rate;
  final int? taxCodeId;
  final double? taxRate;

  /// How much of this line is still returnable — original `qty` minus
  /// whatever other returns already referencing this document have taken.
  /// Falls back to `qty` if the server hasn't annotated it (defensive only;
  /// the `/admin/sales-invoices/{id}` and `/admin/purchase-bills/{id}` show
  /// endpoints always include it).
  final double remainingQty;

  ReturnLookupLine({
    required this.productId,
    required this.qty,
    required this.rate,
    this.taxCodeId,
    this.taxRate,
    double? remainingQty,
  }) : remainingQty = remainingQty ?? qty;

  factory ReturnLookupLine.fromJson(Map<String, dynamic> json) {
    final taxCode = json['tax_code'] ?? json['taxCode'];
    return ReturnLookupLine(
      productId: asInt(json['product_id']),
      qty: asDouble(json['qty']),
      rate: asDouble(json['rate']),
      taxCodeId: asIntOrNull(json['tax_code_id']),
      taxRate: taxCode is Map<String, dynamic> ? asDoubleOrNull(taxCode['rate']) : null,
      remainingQty: asDoubleOrNull(json['remaining_qty']),
    );
  }
}

/// Mirrors the web POS's `buildReturnCartFromSalesInvoice` /
/// `buildReturnCartFromPurchaseBill` — result of looking up an original bill
/// by number so its lines can be loaded into a return cart for adjustment.
class ReturnLookupResult {
  final int documentId;
  final String documentNo;
  final int? partyId;

  /// Sales invoices carry a separate `vendor_id` — which salesperson/vendor
  /// the *sale* is attributed to for reporting, distinct from `partyId`
  /// (the customer). Only populated by [fromSalesInvoiceJson]; `null` for
  /// purchase bills, where [partyId] already carries the vendor.
  final int? attributionVendorId;
  final List<ReturnLookupLine> lines;

  ReturnLookupResult({
    required this.documentId,
    required this.documentNo,
    this.partyId,
    this.attributionVendorId,
    required this.lines,
  });

  factory ReturnLookupResult.fromSalesInvoiceJson(Map<String, dynamic> json) {
    final lines = (json['lines'] as List? ?? const [])
        .map((line) => ReturnLookupLine.fromJson(line as Map<String, dynamic>))
        .toList();
    return ReturnLookupResult(
      documentId: asInt(json['id']),
      documentNo: json['invoice_no'] as String? ?? '',
      partyId: asIntOrNull(json['customer_id']),
      attributionVendorId: asIntOrNull(json['vendor_id']),
      lines: lines,
    );
  }

  factory ReturnLookupResult.fromPurchaseBillJson(Map<String, dynamic> json) {
    final lines = (json['lines'] as List? ?? const [])
        .map((line) => ReturnLookupLine.fromJson(line as Map<String, dynamic>))
        .toList();
    return ReturnLookupResult(
      documentId: asInt(json['id']),
      documentNo: json['bill_no'] as String? ?? '',
      partyId: asIntOrNull(json['vendor_id']),
      lines: lines,
    );
  }
}
