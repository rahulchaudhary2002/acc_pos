import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/company.dart';
import '../models/party.dart';
import '../models/purchase_cart_item.dart';
import '../providers/buy_cart_provider.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
import '../providers/voice_announcer.dart';
import '../services/pos_service.dart';
import '../widgets/action_row_button.dart';
import '../widgets/cart_panel_header.dart';
import '../widgets/pos_screen_header.dart';
import '../widgets/product_picker_dialog.dart';
import '../widgets/purchase_cart_line_tile.dart';
import '../widgets/purchase_invoice_preview_dialog.dart';

/// Buy tab: New Purchase plus an inline Purchase Return mode — mirrors
/// `PosTerminal.jsx`'s `buyMode: "purchase" | "return"` toggle.
class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  String _mode = 'purchase'; // 'purchase' | 'return'
  Party? _selectedVendor;
  DateTime _purchaseDate = DateTime.now();
  final _vendorNameController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<PurchaseCartItem> _returnItems = [];
  Party? _returnVendor;

  // Web `buyReturnTotals`: subtotal = Σ qty×rate, tax = Σ line tax,
  // total = subtotal + tax.
  double get _returnSubtotal => _returnItems.fold(0, (sum, i) => sum + i.lineTotal);
  double get _returnTaxTotal => _returnItems.fold(0, (sum, i) => sum + i.lineTax);
  double get _returnTotal => _returnSubtotal + _returnTaxTotal;

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _vendorNameController.dispose();
    super.dispose();
  }

  void _announce(String key) => context.read<VoiceAnnouncer>().announceAction(key);

  Future<void> _submit() async {
    final cart = context.read<BuyCartProvider>();
    final config = context.read<PosConfigProvider>();
    if (cart.isEmpty) return;
    final vendorName = _vendorNameController.text.trim();
    if (_selectedVendor == null && vendorName.isEmpty) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.buyScreenSelectVendorError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final service = context.read<PosService>();
      final result = await service.buy(
        companyId: config.selectedCompanyId!,
        outletId: config.selectedOutletId!,
        locationId: config.selectedLocationId,
        fiscalYearId: config.selectedFiscalYearId,
        vendorId: _selectedVendor?.id,
        supplierName: _selectedVendor == null ? vendorName : null,
        invoiceNumber: _invoiceNumberController.text.trim(),
        transactionDate: DateFormat('yyyy-MM-dd').format(_purchaseDate),
        items: cart.items,
      );
      if (!mounted) return;
      final company = config.companies.firstWhere((c) => c.id == config.selectedCompanyId, orElse: () => Company(id: 0, name: 'Company'));
      final matchingOutlets = config.outlets.where((o) => o.id == config.selectedOutletId);
      final outlet = matchingOutlets.isEmpty ? null : matchingOutlets.first;
      final itemsSnapshot = List.of(cart.items);
      final vendorNameSnapshot = _selectedVendor?.name ?? vendorName;
      final vendorVatSnapshot = _selectedVendor?.panVatNo;
      final vendorInvoiceNoSnapshot = _invoiceNumberController.text.trim();
      final billDateSnapshot = _purchaseDate;
      final preparedBy = context.read<AuthProvider>().user?.name;
      _clearForm(cart);
      _announce('purchaseCompleted');
      // Mirrors PosTerminal.jsx: refetch products AND parties after a
      // purchase. A typed-in supplier name creates that vendor server-side
      // (PosService.buy()'s named-vendor path) without adding it to
      // PosDataProvider.suppliers locally, so without this refetch the new
      // vendor silently never appears in the supplier picker next time.
      final posData = context.read<PosDataProvider>();
      unawaited(posData.loadProducts(
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            locationId: config.selectedLocationId,
          ));
      unawaited(posData.loadParties(companyId: config.selectedCompanyId));
      await showPurchaseInvoicePreview(
        context,
        result: result,
        items: itemsSnapshot,
        company: company,
        outlet: outlet,
        vendorName: vendorNameSnapshot,
        vendorVatNumber: vendorVatSnapshot,
        vendorInvoiceNo: vendorInvoiceNoSnapshot,
        billDate: billDateSnapshot,
        preparedBy: preparedBy,
      );
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _clearForm(BuyCartProvider cart) {
    cart.clear();
    setState(() {
      _selectedVendor = null;
      _purchaseDate = DateTime.now();
      _vendorNameController.clear();
      _invoiceNumberController.clear();
    });
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      // Backend rejects future dates (`before_or_equal:today`).
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submitReturn() async {
    if (_returnItems.isEmpty) return;
    if (_returnVendor == null) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.buyScreenSelectReturnSupplierError);
      return;
    }
    final config = context.read<PosConfigProvider>();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final service = context.read<PosService>();
      final result = await service.purchaseReturn(
        companyId: config.selectedCompanyId!,
        outletId: config.selectedOutletId!,
        locationId: config.selectedLocationId,
        vendorId: _returnVendor!.id,
        items: _returnItems,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.buyScreenReturnCompletedMessage(
              result.documentNo,
              result.total.toStringAsFixed(2),
            ),
          ),
        ),
      );
      setState(() {
        _returnItems.clear();
        _returnVendor = null;
      });
      unawaited(context.read<PosDataProvider>().loadProducts(
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            locationId: config.selectedLocationId,
          ));
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<BuyCartProvider>();
    final data = context.watch<PosDataProvider>();

    return Column(
      children: [
        PosScreenHeader(
          title: AppLocalizations.of(context)!.buyScreenTitle,
          subtitle: AppLocalizations.of(context)!.buyScreenSubtitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  ErrorBanner(message: _errorMessage!, onDismiss: () => setState(() => _errorMessage = null)),
                Row(
                  children: [
                    Expanded(
                      child: ActionRowButton(
                        icon: Icons.shopping_bag,
                        label: AppLocalizations.of(context)!.buyScreenNewPurchaseLabel,
                        subtitle: AppLocalizations.of(context)!.buyScreenNewPurchaseSubtitle,
                        active: _mode == 'purchase',
                        activeColor: AppColors.info,
                        activeBorderColor: AppColors.borderInfoActive,
                        onTap: () => setState(() => _mode = 'purchase'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.field),
                    Expanded(
                      child: ActionRowButton(
                        icon: Icons.undo,
                        label: AppLocalizations.of(context)!.buyScreenPurchaseReturnLabel,
                        subtitle: AppLocalizations.of(context)!.buyScreenPurchaseReturnSubtitle,
                        active: _mode == 'return',
                        activeColor: AppColors.warningDark,
                        activeBorderColor: AppColors.borderWarningActive,
                        onTap: () => setState(() => _mode = 'return'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.card),
                if (_mode == 'return') ..._buildReturnMode(data) else ..._buildPurchaseMode(cart, data),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPurchaseMode(BuyCartProvider cart, PosDataProvider data) {
    return [
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
              children: [
                const Icon(Icons.storefront_outlined, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.field),
                Text(AppLocalizations.of(context)!.buyScreenPurchaseFromSupplierHeader, style: AppTextStyles.cardHeader),
              ],
            ),
            const SizedBox(height: AppSpacing.card),
            TextField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.buyScreenInvoiceNumberLabel),
            ),
            const SizedBox(height: AppSpacing.item),
            InkWell(
              onTap: _pickPurchaseDate,
              borderRadius: BorderRadius.circular(AppRadius.input),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.buyScreenPurchaseDateLabel,
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(DateFormat('MM/dd/yyyy').format(_purchaseDate)),
              ),
            ),
            const SizedBox(height: AppSpacing.item),
            DropdownButtonFormField<Party>(
              isExpanded: true,
              initialValue: _selectedVendor,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.buyScreenVendorLabel),
              items: data.suppliers
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedVendor = v),
            ),
            const SizedBox(height: AppSpacing.item),
            TextField(
              controller: _vendorNameController,
              enabled: _selectedVendor == null,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.buyScreenVendorNameLabel),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.card),
      // Purchase Summary + Totals live in one continuous white card, matching
      // the reference design — not two separate boxes.
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.section),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            CartPanelHeader(
              icon: Icons.shopping_bag,
              title: AppLocalizations.of(context)!.buyScreenPurchaseSummaryTitle,
              itemCount: cart.itemCount,
              total: cart.netTotal,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cart.isEmpty
                      ? EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: AppLocalizations.of(context)!.buyScreenNoItemsSelectedTitle,
                          subtitle: AppLocalizations.of(context)!.buyScreenNoItemsSelectedSubtitle,
                          action: ElevatedButton(
                            onPressed: () => showProductPicker(context, showPrice: false, showOutOfStockBadge: false, onSelected: (p) {
                              cart.addProduct(p);
                              _announce('productAdded');
                            }),
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            ),
                            child: Text(AppLocalizations.of(context)!.buyScreenAddProductsLabel),
                          ),
                        )
                      : Column(
                          children: List.generate(cart.items.length, (index) {
                            final item = cart.items[index];
                            return PurchaseCartLineTile(
                              name: item.product.name,
                              qty: item.qty,
                              unitCost: item.unitCost,
                              lineTotal: item.lineTotal,
                              onIncrement: () => cart.incrementQty(index),
                              onDecrement: () => cart.decrementQty(index),
                              onQtyChanged: (v) => cart.updateQty(index, v),
                              onUnitCostChanged: (v) => cart.updateUnitCost(index, v),
                              onRemove: () {
                                cart.removeAt(index);
                                _announce('productRemoved');
                              },
                            );
                          }),
                        ),
                  if (!cart.isEmpty) const SizedBox(height: AppSpacing.card),
                  if (!cart.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showProductPicker(context, showPrice: false, showOutOfStockBadge: false, onSelected: (p) {
                              cart.addProduct(p);
                              _announce('productAdded');
                            }),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.buyScreenAddMoreProductsLabel),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.card),
                  _row(AppLocalizations.of(context)!.buyScreenSubtotalLabel, 'NPR ${cart.subtotal.toStringAsFixed(2)}'),
                  _row(AppLocalizations.of(context)!.buyScreenVatLabel, 'NPR ${cart.taxTotal.toStringAsFixed(2)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.field),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  _row(AppLocalizations.of(context)!.buyScreenTotalPurchaseLabel, 'NPR ${cart.netTotal.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.card),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      _clearForm(cart);
                      _announce('cartClearedBuy');
                    },
              style: AppButtonStyles.filled(AppColors.danger),
              child: Text(AppLocalizations.of(context)!.buyScreenClearPurchaseLabel),
            ),
          ),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: ElevatedButton(
              onPressed: (cart.isEmpty || _isSubmitting) ? null : _submit,
              style: AppButtonStyles.filled(AppColors.success),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppLocalizations.of(context)!.buyScreenSavePurchaseLabel),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildReturnMode(PosDataProvider data) {
    return [
      Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AppColors.warningTint,
          borderRadius: BorderRadius.circular(AppRadius.section),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppColors.warningDark),
                const SizedBox(width: AppSpacing.field),
                Text(AppLocalizations.of(context)!.buyScreenPurchaseReturnLabel, style: AppTextStyles.subsectionTitle),
              ],
            ),
            const SizedBox(height: AppSpacing.item),
            Text(AppLocalizations.of(context)!.buyScreenSupplierLabel, style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButtonFormField<Party>(
              isExpanded: true,
              initialValue: _returnVendor,
              decoration: const InputDecoration(filled: true, fillColor: AppColors.surface),
              items: data.suppliers
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _returnVendor = v),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.card),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.section),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            CartPanelHeader(
              icon: Icons.trending_up,
              title: AppLocalizations.of(context)!.buyScreenReturnItemsTitle,
              itemCount: _returnItems.length,
              total: _returnTotal,
              background: AppColors.warningDark,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _returnItems.isEmpty
                      ? EmptyState(
                          icon: Icons.assignment_return_outlined,
                          title: AppLocalizations.of(context)!.buyScreenNoItemsToReturnTitle,
                          action: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warningDark,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            ),
                            onPressed: () => showProductPicker(
                              context,
                              showPrice: false,
                              showOutOfStockBadge: false,
                              onSelected: (p) => setState(() => _returnItems.add(PurchaseCartItem(product: p))),
                            ),
                            child: Text(AppLocalizations.of(context)!.buyScreenAddProductsLabel),
                          ),
                        )
                      : Column(
                          children: List.generate(_returnItems.length, (index) {
                            final item = _returnItems[index];
                            return PurchaseCartLineTile(
                              name: item.product.name,
                              qty: item.qty,
                              unitCost: item.unitCost,
                              lineTotal: item.lineTotal,
                              onIncrement: () => setState(() => item.qty += 1),
                              onDecrement: () => setState(() => item.qty = item.qty > 1 ? item.qty - 1 : 1),
                              onQtyChanged: (v) => setState(() => item.qty = v),
                              onUnitCostChanged: (v) => setState(() => item.unitCost = v),
                              onRemove: () => setState(() => _returnItems.removeAt(index)),
                            );
                          }),
                        ),
                  if (_returnItems.isNotEmpty) const SizedBox(height: AppSpacing.card),
                  if (_returnItems.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.warningDark),
                        onPressed: () => showProductPicker(
                          context,
                          showPrice: false,
                          showOutOfStockBadge: false,
                          onSelected: (p) => setState(() => _returnItems.add(PurchaseCartItem(product: p))),
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.buyScreenAddMoreProductsLabel),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.card),
                  _row(AppLocalizations.of(context)!.buyScreenSubtotalLabel, 'NPR ${_returnSubtotal.toStringAsFixed(2)}'),
                  _row(AppLocalizations.of(context)!.buyScreenVatLabel, 'NPR ${_returnTaxTotal.toStringAsFixed(2)}'),
                  _row(AppLocalizations.of(context)!.buyScreenTotalAmountLabel, 'NPR ${_returnTotal.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.card),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _returnItems.isEmpty
                  ? null
                  : () => setState(() {
                        _returnItems.clear();
                        _returnVendor = null;
                      }),
              style: AppButtonStyles.filled(AppColors.danger),
              child: Text(AppLocalizations.of(context)!.buyScreenClearReturnLabel),
            ),
          ),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: ElevatedButton(
              onPressed: (_returnItems.isEmpty || _isSubmitting) ? null : _submitReturn,
              style: AppButtonStyles.filled(AppColors.warningDark),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(AppLocalizations.of(context)!.buyScreenPostReturnLabel),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
      color: bold ? AppColors.textPrimary : AppColors.textTertiary,
    );
    return Row(
      children: [Expanded(child: Text(label, style: style)), Text(value, style: style)],
    );
  }
}
