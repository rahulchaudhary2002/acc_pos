import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../models/breakdown_row.dart';
import '../models/payment_mode_stat.dart';
import '../models/report_metric.dart';
import '../models/top_product.dart';
import '../models/transaction_summary.dart';
import '../models/trend_point.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';
import '../widgets/breakdown_chart_list.dart';
import '../widgets/payment_mode_pie_chart.dart';
import '../widgets/pos_screen_header.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/sales_trend_chart.dart';
import '../widgets/top_products_list.dart';

const _periods = [
  ('today', 'Today'),
  ('yesterday', 'Yesterday'),
  ('last_7_days', 'Last 7 Days'),
  ('last_30_days', 'Last 30 Days'),
  ('this_month', 'This Month'),
  ('last_month', 'Last Month'),
  ('lifetime', 'Lifetime'),
  ('custom', 'Custom Range'),
];

const _tabs = ['Overview', 'Stores', 'Vendors', 'Customers', 'More'];
const _moreTabIndex = 4;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _period = 'this_month';
  DateTimeRange? _customRange;
  bool _isLoading = false;
  String? _error;
  ReportMetrics? _metrics;
  List<TrendPoint> _trend = [];

  final Map<int, bool> _breakdownLoading = {};
  final Map<int, String?> _breakdownError = {};
  final Map<int, List<BreakdownRow>> _breakdownData = {};

  bool _moreLoaded = false;
  bool _moreLoading = false;
  String? _moreError;
  List<TopProduct> _topProducts = [];
  List<PaymentModeStat> _paymentModes = [];
  List<TransactionSummary> _recentSales = [];
  List<TransactionSummary> _recentPurchases = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == _moreTabIndex) {
        _loadMoreTab();
      } else {
        _loadBreakdownForTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_metrics == null && !_isLoading) {
      _load();
    }
  }

  String? get _fromDate => _period == 'custom' && _customRange != null ? DateFormat('yyyy-MM-dd').format(_customRange!.start) : null;
  String? get _toDate => _period == 'custom' && _customRange != null ? DateFormat('yyyy-MM-dd').format(_customRange!.end) : null;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
    );
    if (picked == null) return;
    setState(() {
      _customRange = picked;
      _period = 'custom';
    });
    _load();
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
      final results = await Future.wait([
        service.fetchReports(
          period: _period,
          companyId: config.selectedCompanyId,
          outletId: config.selectedOutletId,
          fromDate: _fromDate,
          toDate: _toDate,
        ),
        service.fetchReportTrend(
          period: _period,
          companyId: config.selectedCompanyId,
          outletId: config.selectedOutletId,
          fromDate: _fromDate,
          toDate: _toDate,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _metrics = results[0] as ReportMetrics;
        _trend = results[1] as List<TrendPoint>;
      });
      _breakdownData.clear();
      _moreLoaded = false;
      if (_tabController.index == _moreTabIndex) {
        _loadMoreTab();
      } else {
        _loadBreakdownForTab(_tabController.index);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreTab() async {
    if (_moreLoaded || _moreLoading) return;
    final config = context.read<PosConfigProvider>();
    if (!config.isReady) return;
    setState(() {
      _moreLoading = true;
      _moreError = null;
    });
    try {
      final service = context.read<PosService>();
      final results = await Future.wait([
        service.fetchTopProducts(period: _period, companyId: config.selectedCompanyId, outletId: config.selectedOutletId, fromDate: _fromDate, toDate: _toDate),
        service.fetchPaymentModeBreakdown(period: _period, companyId: config.selectedCompanyId, outletId: config.selectedOutletId, fromDate: _fromDate, toDate: _toDate),
        service.fetchSalesList(period: _period, companyId: config.selectedCompanyId, outletId: config.selectedOutletId, fromDate: _fromDate, toDate: _toDate),
        service.fetchPurchasesList(period: _period, companyId: config.selectedCompanyId, outletId: config.selectedOutletId, fromDate: _fromDate, toDate: _toDate),
      ]);
      if (!mounted) return;
      setState(() {
        _topProducts = results[0] as List<TopProduct>;
        _paymentModes = results[1] as List<PaymentModeStat>;
        _recentSales = results[2] as List<TransactionSummary>;
        _recentPurchases = results[3] as List<TransactionSummary>;
        _moreLoaded = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _moreError = e.message);
    } finally {
      if (mounted) setState(() => _moreLoading = false);
    }
  }

  Future<void> _loadBreakdownForTab(int index) async {
    if (index == 0 || _breakdownData.containsKey(index) || _breakdownLoading[index] == true) return;
    final config = context.read<PosConfigProvider>();
    if (!config.isReady) return;
    setState(() {
      _breakdownLoading[index] = true;
      _breakdownError[index] = null;
    });
    try {
      final service = context.read<PosService>();
      List<BreakdownRow> rows;
      switch (index) {
        case 1:
          rows = await service.fetchStoreWiseReport(
            period: _period,
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            fromDate: _fromDate,
            toDate: _toDate,
          );
          break;
        case 2:
          rows = await service.fetchVendorWiseReport(period: _period, companyId: config.selectedCompanyId, fromDate: _fromDate, toDate: _toDate);
          break;
        case 3:
        default:
          rows = await service.fetchCustomerWiseReport(
            period: _period,
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            fromDate: _fromDate,
            toDate: _toDate,
          );
      }
      if (!mounted) return;
      setState(() => _breakdownData[index] = rows);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _breakdownError[index] = e.message);
    } finally {
      if (mounted) setState(() => _breakdownLoading[index] = false);
    }
  }

  String get _periodLabel {
    if (_period == 'custom' && _customRange != null) {
      final fmt = DateFormat('d MMM');
      return '${fmt.format(_customRange!.start)} – ${fmt.format(_customRange!.end)}';
    }
    return _periods.firstWhere((p) => p.$1 == _period).$2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PosScreenHeader(title: 'Reports', subtitle: 'Sales & Inventory Reports', icon: Icons.bar_chart),
        _periodBar(),
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.info,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.info,
            labelStyle: AppTextStyles.tabLabel,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _overviewTab(),
              _breakdownTab(index: 1, nameOf: (r) => r.outletName ?? '-', valueOf: (r) => r.totalSales, color: AppColors.success),
              _breakdownTab(index: 2, nameOf: (r) => r.vendorName ?? '-', valueOf: (r) => r.totalPurchases, color: AppColors.warningDark),
              _breakdownTab(index: 3, nameOf: (r) => r.customerName ?? '-', valueOf: (r) => r.totalSales, color: AppColors.info),
              _moreTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overviewTab() {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!, onDismiss: () => setState(() => _error = null)),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_metrics != null) ...[
              _card(
                title: 'Sales vs Purchases Trend',
                icon: Icons.show_chart,
                child: SalesTrendChart(points: _trend),
              ),
              const SizedBox(height: AppSpacing.card),
              ..._buildMetrics(_metrics!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breakdownTab({
    required int index,
    required String Function(BreakdownRow) nameOf,
    required double Function(BreakdownRow) valueOf,
    required Color color,
  }) {
    final loading = _breakdownLoading[index] == true;
    final error = _breakdownError[index];
    final rows = _breakdownData[index];

    return RefreshIndicator(
      onRefresh: () {
        _breakdownData.remove(index);
        return _loadBreakdownForTab(index);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.card),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ErrorBanner(message: error, onDismiss: () => setState(() => _breakdownError[index] = null)),
            if (loading && rows == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _card(
                title: '${_tabs[index]} · $_periodLabel',
                icon: Icons.bar_chart,
                child: BreakdownChartList(rows: rows ?? [], nameOf: nameOf, valueOf: valueOf, color: color),
              ),
          ],
        ),
      ),
    );
  }

  Widget _moreTab() {
    return RefreshIndicator(
      onRefresh: () {
        _moreLoaded = false;
        return _loadMoreTab();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.card),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_moreError != null) ErrorBanner(message: _moreError!, onDismiss: () => setState(() => _moreError = null)),
            if (_moreLoading && !_moreLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _card(
                title: 'Top Products · $_periodLabel',
                icon: Icons.star,
                child: TopProductsList(products: _topProducts),
              ),
              const SizedBox(height: AppSpacing.card),
              _card(
                title: 'Sales by Payment Mode · $_periodLabel',
                icon: Icons.pie_chart,
                child: PaymentModePieChart(stats: _paymentModes),
              ),
              const SizedBox(height: AppSpacing.card),
              _card(
                title: 'Recent Sales',
                icon: Icons.receipt_long,
                child: RecentTransactionsList(items: _recentSales, color: AppColors.success),
              ),
              const SizedBox(height: AppSpacing.card),
              _card(
                title: 'Recent Purchases',
                icon: Icons.local_shipping,
                child: RecentTransactionsList(items: _recentPurchases, color: AppColors.warningDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Sits between the header and the TabBar so the selected period stays
  // visible and applies consistently across every tab (Overview, Stores,
  // Vendors, Customers, More all filter by it).
  Widget _periodBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card, vertical: AppSpacing.field),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.field),
          const Text('Period:', style: AppTextStyles.label),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _period,
                items: _periods.map((p) => DropdownMenuItem(value: p.$1, child: Text(p.$2))).toList(),
                selectedItemBuilder: (context) {
                  return _periods.map((p) {
                    final label = p.$1 == 'custom' && _customRange != null ? _periodLabel : p.$2;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  if (value == null) return;
                  if (value == 'custom') {
                    _pickCustomRange();
                    return;
                  }
                  setState(() => _period = value);
                  _load();
                },
              ),
            ),
          ),
          if (_period == 'custom')
            IconButton(
              icon: const Icon(Icons.edit_calendar, size: 20, color: AppColors.info),
              tooltip: 'Change date range',
              onPressed: _pickCustomRange,
            ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
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
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.field),
              Expanded(child: Text(title, style: AppTextStyles.cardHeader)),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          child,
        ],
      ),
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
      const SizedBox(height: AppSpacing.item),
      _metricCard(icon: Icons.receipt, title: 'VAT Paid', metric: m.vatPaid, subtitle: 'On posted purchase bills · $_periodLabel'),
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
