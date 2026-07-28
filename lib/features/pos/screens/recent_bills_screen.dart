import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../models/transaction_summary.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
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
  int? _cancellingId;

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
        service.fetchPurchasesList(
          companyId: config.selectedCompanyId,
          outletId: config.selectedOutletId,
          statuses: const ['posted', 'cancelled'],
        ),
        service.fetchSalesList(
          companyId: config.selectedCompanyId,
          outletId: config.selectedOutletId,
          statuses: const ['posted', 'cancelled'],
        ),
      ]);
      if (!mounted) return;
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      bool withinLast24Hours(TransactionSummary t) => t.createdAt != null && !t.createdAt!.isBefore(cutoff);
      setState(() {
        _purchases = results[0].where(withinLast24Hours).toList();
        _sales = results[1].where(withinLast24Hours).toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Refetches product stock after a cancellation — cancelling reverses the
  /// bill's stock movement server-side, but `PosDataProvider.products` (the
  /// Sell/Buy screens' cached stock quantities) won't reflect that until
  /// re-fetched, mirroring the refresh `sell_screen.dart`/`buy_screen.dart`
  /// already do right after completing a sale/purchase.
  void _refreshProductStock() {
    final config = context.read<PosConfigProvider>();
    unawaited(context.read<PosDataProvider>().loadProducts(
          companyId: config.selectedCompanyId,
          outletId: config.selectedOutletId,
          locationId: config.selectedLocationId,
        ));
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

  /// Cancels a posted purchase bill/sales invoice — reverses its stock
  /// movement and linked journal vouchers server-side, mirroring the web
  /// admin's "Cancel" action. The server only allows this within 24 hours of
  /// creation; this screen already only lists rows from the last 24 hours
  /// (see [_load]), so every visible row is eligible when tapped.
  Future<void> _cancelPurchase(TransactionSummary item) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await _promptCancelReason(
      title: l10n.recentBillsScreenCancelPurchaseDialogTitle,
      message: l10n.recentBillsScreenCancelPurchaseDialogMessage,
    );
    if (reason == null || !mounted) return;

    setState(() => _cancellingId = item.id);
    try {
      final service = context.read<PosService>();
      final data = await service.cancelPurchaseBill(item.id, reason);
      if (!mounted) return;
      setState(() {
        _purchases = _purchases
            .map((p) => p.id == item.id && data != null ? TransactionSummary.fromPurchaseJson(data) : p)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recentBillsScreenCancelPurchaseSuccess)));
      _refreshProductStock();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  /// Sales-invoice counterpart of [_cancelPurchase].
  Future<void> _cancelSale(TransactionSummary item) async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await _promptCancelReason(
      title: l10n.recentBillsScreenCancelSaleDialogTitle,
      message: l10n.recentBillsScreenCancelSaleDialogMessage,
    );
    if (reason == null || !mounted) return;

    setState(() => _cancellingId = item.id);
    try {
      final service = context.read<PosService>();
      final data = await service.cancelSalesInvoice(item.id, reason);
      if (!mounted) return;
      setState(() {
        _sales = _sales
            .map((s) => s.id == item.id && data != null ? TransactionSummary.fromSaleJson(data) : s)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recentBillsScreenCancelSaleSuccess)));
      _refreshProductStock();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  /// Shows the cancellation-reason dialog (bill preview title/message +
  /// required reason textarea, mirroring the web admin's cancel modal) and
  /// returns the trimmed reason, or null if the user backed out / left it
  /// blank.
  Future<String?> _promptCancelReason({required String title, required String message}) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? error;
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 12),
              Text(l10n.recentBillsScreenCancelReasonLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.recentBillsScreenCancelReasonPlaceholder,
                  errorText: error,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.recentBillsScreenKeepButton)),
            TextButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) {
                  setDialogState(() => error = l10n.recentBillsScreenCancelReasonRequired);
                  return;
                }
                Navigator.pop(dialogContext, trimmed);
              },
              child: Text(l10n.recentBillsScreenCancelConfirmButton),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return reason;
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
              _list(items: _purchases, color: AppColors.warningDark, emptyMessage: l10n.recentBillsScreenEmptyPurchase, onPrint: _printPurchase, onCancel: _cancelPurchase),
              _list(items: _sales, color: AppColors.success, emptyMessage: l10n.recentBillsScreenEmptySales, onPrint: _printSale, onCancel: _cancelSale),
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
    required void Function(TransactionSummary item) onCancel,
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
                onCancel: onCancel,
                cancellingId: _cancellingId,
              ),
          ],
        ),
      ),
    );
  }
}
