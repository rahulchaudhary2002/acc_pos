import 'json_utils.dart' as json_utils;

/// Row shape shared by the three "-wise" breakdown reports (store/vendor/
/// customer). Each endpoint returns different columns, so fields are optional
/// and the UI only renders the ones present for that report type.
class BreakdownRow {
  final int? outletId;
  final String? outletName;
  final int? vendorId;
  final String? vendorName;
  final int? customerId;
  final String? customerName;
  final String? panVatNo;
  final double totalSales;
  final double totalPurchases;
  final int count;
  final double totalVat;

  BreakdownRow({
    this.outletId,
    this.outletName,
    this.vendorId,
    this.vendorName,
    this.customerId,
    this.customerName,
    this.panVatNo,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.count = 0,
    this.totalVat = 0,
  });

  factory BreakdownRow.fromJson(Map<String, dynamic> json) {
    // Raw SQL SUM()/COUNT() aggregates come back as strings from the query
    // builder (e.g. "0.0000"), not native JSON numbers — parse defensively.
    double asDouble(dynamic v) => v == null ? 0 : double.parse(v.toString());
    int asInt(dynamic v) => v == null ? 0 : int.parse(v.toString());

    return BreakdownRow(
      outletId: json_utils.asIntOrNull(json['outlet_id']),
      outletName: json['outlet_name'] as String?,
      vendorId: json_utils.asIntOrNull(json['vendor_id']),
      vendorName: json['vendor_name'] as String?,
      customerId: json_utils.asIntOrNull(json['customer_id']),
      customerName: json['customer_name'] as String?,
      panVatNo: json['pan_vat_no'] as String?,
      totalSales: asDouble(json['total_sales']),
      totalPurchases: asDouble(json['total_purchases']),
      count: asInt(json['sales_count'] ?? json['purchase_count'] ?? json['invoice_count']),
      totalVat: asDouble(json['sales_vat'] ?? json['total_vat']),
    );
  }
}
