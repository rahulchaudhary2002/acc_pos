import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/party_ledger_row.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';

/// Vendor Ledger / Customer Ledger: one summary row per party (opening
/// balance, debit, credit, closing balance) for a date range, backed by
/// `GET /admin/reports/vendor-ledger` / `customer-ledger`.
class PartyLedgerScreen extends StatefulWidget {
  final bool isCustomer;

  const PartyLedgerScreen({super.key, required this.isCustomer});

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  bool _isLoading = false;
  String? _error;
  List<PartyLedgerRow> _rows = [];
  DateTimeRange? _range;
  String _search = '';

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
      final rows = widget.isCustomer
          ? await service.fetchCustomerLedger(companyId: config.selectedCompanyId, fromDate: _fromDate, toDate: _toDate)
          : await service.fetchVendorLedger(companyId: config.selectedCompanyId, fromDate: _fromDate, toDate: _toDate);
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

  List<PartyLedgerRow> get _filteredRows {
    if (_search.trim().isEmpty) return _rows;
    final q = _search.trim().toLowerCase();
    return _rows.where((r) => r.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.isCustomer ? l10n.partyLedgerScreenCustomerTitle : l10n.partyLedgerScreenVendorTitle;
    final rangeLabel = _range == null
        ? l10n.partyLedgerScreenAllTime
        : '${DateFormat('d MMM yyyy').format(_range!.start)} – ${DateFormat('d MMM yyyy').format(_range!.end)}';

    final totalDebit = _filteredRows.fold<double>(0, (sum, r) => sum + r.totalDebit);
    final totalCredit = _filteredRows.fold<double>(0, (sum, r) => sum + r.totalCredit);
    final totalBalance = _filteredRows.fold<double>(0, (sum, r) => sum + r.balance);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                      hintText: l10n.partyLedgerScreenSearchHint,
                    ),
                    onChanged: (value) => setState(() => _search = value),
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
                      else if (_filteredRows.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text(l10n.partyLedgerScreenEmptyMessage, style: AppTextStyles.helper)),
                        )
                      else ...[
                        _summaryCard(l10n, totalDebit, totalCredit, totalBalance),
                        const SizedBox(height: AppSpacing.card),
                        ..._filteredRows.map(_partyRow),
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

  Widget _summaryCard(AppLocalizations l10n, double debit, double credit, double balance) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.section),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _summaryStat(l10n.partyLedgerScreenTotalDebit, debit, AppColors.warningDark)),
          Expanded(child: _summaryStat(l10n.partyLedgerScreenTotalCredit, credit, AppColors.success)),
          Expanded(child: _summaryStat(l10n.partyLedgerScreenNetBalance, balance, AppColors.info)),
        ],
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

  Widget _partyRow(PartyLedgerRow row) {
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
          Text(row.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              if (row.openingBalance != null) Expanded(child: _kv('OB', row.openingBalance!)),
              Expanded(child: _kv('Dr', row.totalDebit, color: AppColors.warningDark)),
              Expanded(child: _kv('Cr', row.totalCredit, color: AppColors.success)),
              Expanded(child: _kv('Bal', row.balance, color: AppColors.info, bold: true)),
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
