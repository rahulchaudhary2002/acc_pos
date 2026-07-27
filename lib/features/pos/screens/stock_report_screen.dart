import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/stock_report_row.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';

/// Current stock position per product/location, backed by
/// `GET /admin/reports/stock-balance`.
class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  bool _isLoading = false;
  String? _error;
  List<StockReportRow> _rows = [];
  String _search = '';
  int? _locationId;
  bool _showZeroStock = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _rows.isEmpty && _error == null) {
      final config = context.read<PosConfigProvider>();
      _locationId ??= config.selectedLocationId;
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
      final rows = await service.fetchStockReport(
        companyId: config.selectedCompanyId,
        outletId: config.selectedOutletId,
        locationId: _locationId,
        search: _search.isEmpty ? null : _search,
        showZeroStock: _showZeroStock,
      );
      if (!mounted) return;
      setState(() => _rows = rows);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = context.watch<PosConfigProvider>();
    final locations = config.locationsForSelectedOutlet();
    final totalValue = _rows.fold<double>(0, (sum, r) => sum + r.stockValue);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockReportScreenTitle)),
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
                      hintText: l10n.stockReportScreenSearchHint,
                    ),
                    onSubmitted: (value) {
                      setState(() => _search = value);
                      _load();
                    },
                  ),
                  const SizedBox(height: AppSpacing.field),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          isExpanded: true,
                          initialValue: _locationId,
                          decoration: InputDecoration(labelText: l10n.stockReportScreenWarehouseLabel),
                          items: [
                            DropdownMenuItem(value: null, child: Text(l10n.stockReportScreenAllWarehouses)),
                            ...locations.map((loc) => DropdownMenuItem(value: loc.id, child: Text(loc.name, overflow: TextOverflow.ellipsis))),
                          ],
                          onChanged: (value) {
                            setState(() => _locationId = value);
                            _load();
                          },
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.stockReportScreenShowZeroStock, style: AppTextStyles.label),
                    value: _showZeroStock,
                    onChanged: (value) {
                      setState(() => _showZeroStock = value);
                      _load();
                    },
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
                      else if (_rows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text(l10n.stockReportScreenEmptyMessage, style: AppTextStyles.helper)),
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
                              Text(l10n.stockReportScreenTotalValueLabel(_rows.length), style: AppTextStyles.label),
                              Text('NPR ${totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.info)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.card),
                        ..._rows.map(_stockRow),
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

  Widget _stockRow(StockReportRow row) {
    final isLow = row.minStock != null && row.minStock! > 0 && row.qty <= row.minStock!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.field),
      decoration: BoxDecoration(
        color: isLow ? AppColors.warningTint : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: isLow ? AppColors.borderWarning : AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text('${row.sku} · ${row.locationName}', style: AppTextStyles.tiny),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${row.qty.toStringAsFixed(2)} ${row.unitCode ?? ''}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isLow ? AppColors.warningDark : AppColors.textSecondary)),
              Text('NPR ${row.stockValue.toStringAsFixed(0)}', style: AppTextStyles.tiny),
            ],
          ),
        ],
      ),
    );
  }
}
