import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/transaction_summary.dart';
import '../providers/pos_config_provider.dart';
import '../services/pos_service.dart';
import '../widgets/historical_invoice_preview.dart';
import '../widgets/pos_screen_header.dart';
import '../widgets/recent_transactions_list.dart';

/// Dedicated "Recent Bills" tab: a Purchase Bills / Sales Invoices tab view,
/// mirroring the web POS's Recent Bills tab — unlike the Reports "More" tab,
/// this isn't capped to a top-10 preview.
class RecentBillsScreen extends StatefulWidget {
  const RecentBillsScreen({super.key});

  @override
  State<RecentBillsScreen> createState() => _RecentBillsScreenState();
}

class _RecentBillsScreenState extends State<RecentBillsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = false;
  String? _error;
  List<TransactionSummary> _purchases = [];
  List<TransactionSummary> _sales = [];
  int? _printingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _purchases.isEmpty && _sales.isEmpty && _error == null) {
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
      final results = await Future.wait([
        service.fetchPurchasesList(companyId: config.selectedCompanyId, outletId: config.selectedOutletId),
        service.fetchSalesList(companyId: config.selectedCompanyId, outletId: config.selectedOutletId),
      ]);
      if (!mounted) return;
      setState(() {
        _purchases = results[0];
        _sales = results[1];
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _printPurchase(TransactionSummary item) async {
    setState(() => _printingId = item.id);
    try {
      final service = context.read<PosService>();
      final bill = await service.fetchPurchaseBillDetail(item.id);
      if (!mounted) return;
      await showHistoricalPurchaseBillPreview(context, bill: bill);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _printingId = null);
    }
  }

  Future<void> _printSale(TransactionSummary item) async {
    setState(() => _printingId = item.id);
    try {
      final service = context.read<PosService>();
      final invoice = await service.fetchSalesInvoiceDetail(item.id);
      if (!mounted) return;
      await showHistoricalSalesInvoicePreview(context, invoice: invoice);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _printingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        PosScreenHeader(title: l10n.recentBillsScreenTitle, subtitle: l10n.recentBillsScreenSubtitle),
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.info,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.info,
            labelStyle: AppTextStyles.tabLabel,
            tabs: [
              Tab(text: l10n.recentBillsScreenPurchaseTab),
              Tab(text: l10n.recentBillsScreenSalesTab),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _list(items: _purchases, color: AppColors.warningDark, emptyMessage: l10n.recentBillsScreenEmptyPurchase, onPrint: _printPurchase),
              _list(items: _sales, color: AppColors.success, emptyMessage: l10n.recentBillsScreenEmptySales, onPrint: _printSale),
            ],
          ),
        ),
      ],
    );
  }

  Widget _list({
    required List<TransactionSummary> items,
    required Color color,
    required String emptyMessage,
    required void Function(TransactionSummary item) onPrint,
  }) {
    return RefreshIndicator(
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
            else
              RecentTransactionsList(
                items: items,
                color: color,
                emptyMessage: emptyMessage,
                limit: null,
                onPrint: onPrint,
                printingId: _printingId,
              ),
          ],
        ),
      ),
    );
  }
}
