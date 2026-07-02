import 'json_utils.dart';

/// One metric card from `GET /pos/reports` — `{value, count?, trend}`.
class ReportMetric {
  final double value;
  final int? count;
  final double trend;

  ReportMetric({required this.value, this.count, required this.trend});

  factory ReportMetric.fromJson(Map<String, dynamic> json) {
    return ReportMetric(
      value: double.parse(json['value'].toString()),
      count: asIntOrNull(json['count']),
      trend: double.parse(json['trend'].toString()),
    );
  }
}

class ReportMetrics {
  final ReportMetric totalSales;
  final ReportMetric salesReturns;
  final ReportMetric netSales;
  final ReportMetric totalPurchases;
  final ReportMetric purchaseReturns;
  final ReportMetric netPurchases;
  final ReportMetric inventoryValue;
  final ReportMetric vatCollected;
  final ReportMetric vatPaid;
  final ReportMetric netTax;

  ReportMetrics({
    required this.totalSales,
    required this.salesReturns,
    required this.netSales,
    required this.totalPurchases,
    required this.purchaseReturns,
    required this.netPurchases,
    required this.inventoryValue,
    required this.vatCollected,
    required this.vatPaid,
    required this.netTax,
  });

  factory ReportMetrics.fromJson(Map<String, dynamic> data) {
    ReportMetric metric(String key) => ReportMetric.fromJson(data[key] as Map<String, dynamic>);
    return ReportMetrics(
      totalSales: metric('total_sales'),
      salesReturns: metric('sales_returns'),
      netSales: metric('net_sales'),
      totalPurchases: metric('total_purchases'),
      purchaseReturns: metric('purchase_returns'),
      netPurchases: metric('net_purchases'),
      inventoryValue: metric('inventory_value'),
      vatCollected: metric('vat_collected'),
      vatPaid: metric('vat_paid'),
      netTax: metric('net_tax'),
    );
  }
}
