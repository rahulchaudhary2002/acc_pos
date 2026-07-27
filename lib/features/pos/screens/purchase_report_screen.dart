import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/transaction_summary.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';
import '../widgets/recent_transactions_list.dart';

/// Full, filterable list of posted purchase bills — backed by the same
/// `GET /admin/purchase-bills` listing `PosService.fetchPurchasesList`
/// already wraps for the Reports "More" tab preview, but unlimited and with
/// its own date-range + search filters.
class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  bool _isLoading = false;
  String? _error;
  List<TransactionSummary> _items = [];
  DateTimeRange? _range;
  String _search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _items.isEmpty && _error == null) {
      _load();
    }
  }

  String? get _fromDate => _range == null ? null : DateFormat('yyyy-MM-dd').format(_range!.start);
  String? get _toDate => _range == null ? null : DateFormat('yyyy-MM-dd').format(_range!.end);

  Future<void> _load() async {
    final config = context.read<PosConfigProvider>();
    if (!config.isReady) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = context.read<PosService>();
      final items = await service.fetchPurchasesList(
        companyId: config.selectedCompanyId,
        outletId: config.selectedOutletId,
        search: _search.isEmpty ? null : _search,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked == null) return;
    setState(() => _range = picked);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rangeLabel = _range == null
        ? l10n.partyLedgerScreenAllTime
        : '${DateFormat('d MMM yyyy').format(_range!.start)} – ${DateFormat('d MMM yyyy').format(_range!.end)}';
    final totalPurchases = _items.fold<double>(0, (sum, i) => sum + i.total);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseReportScreenTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.purchaseReportScreenSearchHint,
                    ),
                    onSubmitted: (value) {
                      setState(() => _search = value);
                      _load();
                    },
                  ),
                  const SizedBox(height: AppSpacing.field),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.field),
                      Expanded(child: Text(rangeLabel, style: AppTextStyles.label)),
                      TextButton.icon(
                        onPressed: _pickRange,
                        icon: const Icon(Icons.edit_calendar, size: 18),
                        label: Text(l10n.partyLedgerScreenChangeRange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.card),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.section),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.purchaseReportScreenTotalLabel(_items.length), style: AppTextStyles.label),
                              Text('NPR ${totalPurchases.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.warningDark)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.card),
                        RecentTransactionsList(
                          items: _items,
                          color: AppColors.warningDark,
                          emptyMessage: l10n.purchaseReportScreenEmptyMessage,
                          limit: null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
