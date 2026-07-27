import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/vat_summary_row.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';

/// Input/output VAT totals per tax code, backed by
/// `GET /admin/reports/vat-summary`.
class VatReportScreen extends StatefulWidget {
  const VatReportScreen({super.key});

  @override
  State<VatReportScreen> createState() => _VatReportScreenState();
}

class _VatReportScreenState extends State<VatReportScreen> {
  bool _isLoading = false;
  String? _error;
  List<VatSummaryRow> _rows = [];
  DateTimeRange? _range;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _rows.isEmpty && _error == null) {
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
      final rows = await service.fetchVatSummary(companyId: config.selectedCompanyId, fromDate: _fromDate, toDate: _toDate);
      if (!mounted) return;
      setState(() => _rows = rows);
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

    final rowsWithActivity = _rows.where((r) => r.inputTax != 0 || r.outputTax != 0).toList();
    final totalInput = rowsWithActivity.fold<double>(0, (sum, r) => sum + r.inputTax);
    final totalOutput = rowsWithActivity.fold<double>(0, (sum, r) => sum + r.outputTax);
    final totalNet = totalOutput - totalInput;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vatReportScreenTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Row(
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
                      else if (rowsWithActivity.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text(l10n.vatReportScreenEmptyMessage, style: AppTextStyles.helper)),
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
                            children: [
                              Expanded(child: _summaryStat(l10n.vatReportScreenInputTax, totalInput, AppColors.warningDark)),
                              Expanded(child: _summaryStat(l10n.vatReportScreenOutputTax, totalOutput, AppColors.success)),
                              Expanded(
                                child: _summaryStat(
                                  totalNet >= 0 ? l10n.vatReportScreenPayable : l10n.vatReportScreenRefundable,
                                  totalNet.abs(),
                                  AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.card),
                        ...rowsWithActivity.map(_vatRow),
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

  Widget _summaryStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.helper, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('NPR ${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _vatRow(VatSummaryRow row) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.field),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.field),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${row.name} (${row.rate.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _kv(l10n.vatReportScreenInputTax, row.inputTax, color: AppColors.warningDark)),
              Expanded(child: _kv(l10n.vatReportScreenOutputTax, row.outputTax, color: AppColors.success)),
              Expanded(child: _kv(l10n.vatReportScreenNetLabel, row.net, color: AppColors.info, bold: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, double value, {Color? color, bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.tiny),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: color ?? AppColors.textSecondary),
        ),
      ],
    );
  }
}
