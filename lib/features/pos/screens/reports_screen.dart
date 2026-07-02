import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../models/report_metric.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';
import '../widgets/pos_screen_header.dart';

const _periods = [
  ('today', 'Today'),
  ('yesterday', 'Yesterday'),
  ('last_7_days', 'Last 7 Days'),
  ('last_30_days', 'Last 30 Days'),
  ('this_month', 'This Month'),
  ('last_month', 'Last Month'),
  ('lifetime', 'Lifetime'),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'this_month';
  bool _isLoading = false;
  String? _error;
  ReportMetrics? _metrics;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_metrics == null && !_isLoading) {
      _load();
    }
  }

  Future<void> _load() async {
    final config = context.read<PosConfigProvider>();
    if (!config.isReady) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = context.read<PosService>();
      final metrics = await service.fetchReports(
        period: _period,
        companyId: config.selectedCompanyId,
        outletId: config.selectedOutletId,
      );
      if (!mounted) return;
      setState(() => _metrics = metrics);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _periodLabel => _periods.firstWhere((p) => p.$1 == _period).$2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PosScreenHeader(title: 'Reports', subtitle: 'Sales & Inventory Reports', icon: Icons.bar_chart),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ErrorBanner(message: _error!, onDismiss: () => setState(() => _error = null)),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.card),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.section),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.bar_chart, color: AppColors.textSecondary),
                            SizedBox(width: AppSpacing.field),
                            Text('Sales & Inventory Reports', style: AppTextStyles.cardHeader),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.card),
                        const Text('Select Period', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.field),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _period,
                          items: _periods.map((p) => DropdownMenuItem(value: p.$1, child: Text(p.$2))).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _period = value);
                            _load();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.card),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_metrics != null)
                    ..._buildMetrics(_metrics!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMetrics(ReportMetrics m) {
    return [
      _summaryCard(
        icon: Icons.shopping_cart,
        iconColor: AppColors.success,
        borderColor: AppColors.borderSuccess,
        title: 'Monthly Sales (incl. Returns)',
        grossLabel: 'Gross Sales',
        gross: m.totalSales.value,
        returnsLabel: 'Sales Returns',
        returns: m.salesReturns.value,
        returnsCount: m.salesReturns.count ?? 0,
        netLabel: 'Net Sales',
        net: m.netSales.value,
        netColor: AppColors.success,
        countLabel: '${m.totalSales.count ?? 0} invoices',
      ),
      const SizedBox(height: AppSpacing.card),
      _summaryCard(
        icon: Icons.shopping_bag,
        iconColor: AppColors.warningDark,
        borderColor: AppColors.borderWarning,
        title: 'Monthly Purchase (incl. Returns)',
        grossLabel: 'Gross Purchase',
        gross: m.totalPurchases.value,
        returnsLabel: 'Purchase Returns',
        returns: m.purchaseReturns.value,
        returnsCount: m.purchaseReturns.count ?? 0,
        netLabel: 'Net Purchase',
        net: m.netPurchases.value,
        netColor: AppColors.warningDark,
        countLabel: '${m.totalPurchases.count ?? 0} GRNs',
      ),
      const SizedBox(height: AppSpacing.card),
      _metricCard(icon: Icons.shopping_cart, title: 'Total Sales', metric: m.totalSales, subtitle: '${m.totalSales.count ?? 0} posted invoices · $_periodLabel'),
      const SizedBox(height: AppSpacing.item),
      _metricCard(icon: Icons.shopping_bag, title: 'Total Purchases', metric: m.totalPurchases, subtitle: '${m.totalPurchases.count ?? 0} posted stock intakes · $_periodLabel'),
      const SizedBox(height: AppSpacing.item),
      _metricCard(icon: Icons.inventory_2, title: 'Stock Value', metric: m.inventoryValue, subtitle: 'Current inventory on hand'),
      const SizedBox(height: AppSpacing.item),
      _metricCard(icon: Icons.percent, title: 'VAT Collected', metric: m.vatCollected, subtitle: 'Net tax Rs ${m.netTax.value.toStringAsFixed(2)}'),
    ];
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String grossLabel,
    required double gross,
    required String returnsLabel,
    required double returns,
    required int returnsCount,
    required String netLabel,
    required double net,
    required Color netColor,
    required String countLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.section),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.field),
              Expanded(child: Text(title, style: AppTextStyles.cardHeader)),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          _kv(grossLabel, 'Rs ${gross.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _kv(returnsCount > 0 ? '$returnsLabel ($returnsCount)' : returnsLabel, '− Rs ${returns.toStringAsFixed(2)}', valueColor: AppColors.dangerDark),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.field),
            child: Divider(height: 1, color: AppColors.surfaceTotals),
          ),
          _kv(netLabel, 'Rs ${net.toStringAsFixed(2)}', bold: true, valueColor: netColor),
          const SizedBox(height: 6),
          Text(countLabel, style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
        ],
      ),
    );
  }

  Widget _kv(String label, String value, {bool bold = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: bold ? AppColors.textSecondary : AppColors.textTertiary, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        ),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textSecondary)),
      ],
    );
  }

  Widget _metricCard({required IconData icon, required String title, required ReportMetric metric, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.section),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.surfaceTotals, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.card),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                Text('Rs ${metric.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
