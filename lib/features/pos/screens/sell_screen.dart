import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_banner.dart';
import '../models/company.dart';
import '../models/sale_cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
import '../providers/voice_announcer.dart';
import '../services/pos_service.dart';
import '../models/party.dart';
import '../widgets/action_row_button.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/cart_panel_header.dart';
import '../widgets/invoice_preview_dialog.dart';
import '../widgets/payment_type_section.dart';
import '../widgets/pos_screen_header.dart';
import '../widgets/product_picker_dialog.dart';
import '../widgets/totals_block.dart';

/// Sell tab: Cash/Customer sale plus an inline Sales Return mode — mirrors
/// `PosTerminal.jsx`'s `sellMode: "sale" | "return"` toggle (not a separate
/// screen; the action row's third button swaps the whole panel below it).
class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String _mode = 'sale'; // 'sale' | 'return'
  Party? _selectedCustomer;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerVatController = TextEditingController();
  final _customerAddressController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<SaleCartItem> _returnItems = [];
  int? _returnCustomerId;

  double get _returnSubtotal => _returnItems.fold(0, (sum, i) => sum + i.lineSubtotal);
  double get _returnTaxTotal => _returnItems.fold(0, (sum, i) => sum + i.taxAmount);
  double get _returnGrandTotal => _returnSubtotal + _returnTaxTotal;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerVatController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  void _announce(String key) => context.read<VoiceAnnouncer>().announceAction(key);

  void _resetCustomerForm() {
    _selectedCustomer = null;
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerVatController.clear();
    _customerAddressController.clear();
  }

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();
    final config = context.read<PosConfigProvider>();
    if (cart.isEmpty) return;
    final walkInName = _customerNameController.text.trim();
    if (cart.saleType == 'customer' && _selectedCustomer == null && walkInName.isEmpty) {
      setState(() => _errorMessage = 'Select an existing customer or enter a full name for a customer sale.');
      return;
    }
    final vatNumber = _customerVatController.text.trim();
    if (cart.saleType == 'customer' && _selectedCustomer == null && vatNumber.isNotEmpty && !RegExp(r'^[A-Za-z0-9]{10}$').hasMatch(vatNumber)) {
      setState(() => _errorMessage = 'VAT number must be exactly 10 alphanumeric characters.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final service = context.read<PosService>();
      final result = await service.sell(
        companyId: config.selectedCompanyId!,
        outletId: config.selectedOutletId!,
        locationId: config.selectedLocationId,
        saleType: cart.saleType,
        customerId: _selectedCustomer?.id,
        customerName: cart.saleType == 'customer' && _selectedCustomer == null ? walkInName : null,
        customerPhone: cart.saleType == 'customer' && _selectedCustomer == null ? _customerPhoneController.text.trim() : null,
        customerAddress: cart.saleType == 'customer' && _selectedCustomer == null ? _customerAddressController.text.trim() : null,
        customerVatNumber: cart.saleType == 'customer' && _selectedCustomer == null ? _customerVatController.text.trim() : null,
        deliveryCharge: cart.deliveryCharge,
        paymentMode: cart.paymentMode,
        paymentReference: cart.paymentReference,
        paymentNote: cart.paymentMode == 'cash' ? cart.remarks : cart.paymentNote,
        items: cart.items,
      );

      if (!mounted) return;
      final companyName = config.companies.firstWhere((c) => c.id == config.selectedCompanyId, orElse: () => Company(id: 0, name: 'Company')).name;
      final itemsSnapshot = List.of(cart.items);
      final paymentMode = cart.paymentMode;
      final customerNameSnapshot = _selectedCustomer?.name ?? (walkInName.isEmpty ? null : walkInName);
      cart.clear();
      setState(_resetCustomerForm);
      _announce('saleCompleted');
      // Mirrors PosTerminal.jsx: refetch products after a sale so stock
      // reflects this transaction immediately, instead of showing whatever
      // was cached from the last load.
      unawaited(context.read<PosDataProvider>().loadProducts(
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            locationId: config.selectedLocationId,
          ));

      await showInvoicePreview(
        context,
        result: result,
        items: itemsSnapshot,
        companyName: companyName,
        customerName: customerNameSnapshot,
        paymentMode: paymentMode,
      );
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitReturn() async {
    if (_returnItems.isEmpty) return;
    final config = context.read<PosConfigProvider>();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final service = context.read<PosService>();
      final result = await service.sellReturn(
        companyId: config.selectedCompanyId!,
        outletId: config.selectedOutletId!,
        locationId: config.selectedLocationId,
        customerId: _returnCustomerId,
        items: _returnItems,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Return ${result.documentNo} completed — Rs ${result.total.toStringAsFixed(2)}')),
      );
      setState(() {
        _returnItems.clear();
        _returnCustomerId = null;
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
    final cart = context.watch<CartProvider>();
    final data = context.watch<PosDataProvider>();

    return Column(
      children: [
        const PosScreenHeader(title: 'Sell LPG', subtitle: 'Easy POS for Vendors'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null)
                  ErrorBanner(message: _errorMessage!, onDismiss: () => setState(() => _errorMessage = null)),
                if (data.errorMessage != null)
                  ErrorBanner(message: data.errorMessage!),
                Row(
                  children: [
                    Expanded(
                      child: ActionRowButton(
                        icon: Icons.receipt,
                        label: 'Cash Sale',
                        subtitle: 'Up to Rs 25,000',
                        active: _mode == 'sale' && cart.saleType == 'cash',
                        activeColor: AppColors.success,
                        activeBorderColor: AppColors.successActive,
                        onTap: () {
                          setState(() => _mode = 'sale');
                          cart.setSaleType('cash');
                          setState(_resetCustomerForm);
                          _announce('saleTypeCash');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.field),
                    Expanded(
                      child: ActionRowButton(
                        icon: Icons.shopping_cart,
                        label: 'Customer Sale',
                        subtitle: 'Linked account',
                        active: _mode == 'sale' && cart.saleType == 'customer',
                        activeColor: AppColors.info,
                        activeBorderColor: AppColors.borderInfoActive,
                        onTap: () {
                          setState(() => _mode = 'sale');
                          cart.setSaleType('customer');
                          _announce('saleTypeCustomer');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.field),
                    Expanded(
                      child: ActionRowButton(
                        icon: Icons.undo,
                        label: 'Sales Return',
                        subtitle: 'Refund items',
                        active: _mode == 'return',
                        activeColor: AppColors.danger,
                        activeBorderColor: AppColors.borderDangerActive,
                        onTap: () => setState(() => _mode = 'return'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.card),
                if (_mode == 'return') ..._buildReturnMode(data) else ..._buildSaleMode(cart, data),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSaleMode(CartProvider cart, PosDataProvider data) {
    return [
      if (cart.saleType == 'customer') ...[
        _CustomerInfoSection(
          customers: data.customers,
          selectedCustomer: _selectedCustomer,
          onCustomerSelected: (c) => setState(() {
            _selectedCustomer = c;
            if (c != null) {
              _customerNameController.clear();
              _customerPhoneController.clear();
              _customerVatController.clear();
              _customerAddressController.clear();
            }
          }),
          nameController: _customerNameController,
          phoneController: _customerPhoneController,
          vatController: _customerVatController,
          addressController: _customerAddressController,
        ),
        const SizedBox(height: AppSpacing.card),
      ],
      // Current Sale + Totals + Payment Type all live in one continuous
      // white card, matching the reference design — not three separate boxes.
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.section),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            CartPanelHeader(
              icon: Icons.shopping_cart,
              title: 'Current Sale',
              itemCount: cart.itemCount,
              total: cart.grandTotal,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cart.isEmpty
                      ? EmptyState(
                          icon: Icons.shopping_cart_outlined,
                          title: 'No items added yet',
                          subtitle: 'Click the button below to add products',
                          action: ElevatedButton(
                            onPressed: () => showProductPicker(context, disableOutOfStock: true, onSelected: (p) {
                              cart.addProduct(p);
                              _announce('productAdded');
                            }),
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            ),
                            child: const Text('Add Products'),
                          ),
                        )
                      : Column(
                          children: List.generate(cart.items.length, (index) {
                            final item = cart.items[index];
                            return CartLineTile(
                              name: item.product.name,
                              category: item.product.category,
                              qty: item.qty,
                              rate: item.rate,
                              lineTotal: item.lineTotal,
                              onIncrement: () => cart.incrementQty(index),
                              onDecrement: () => cart.decrementQty(index),
                              onQtyChanged: (v) => cart.updateQty(index, v),
                              onRateChanged: (v) => cart.updateRate(index, v),
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
                        onPressed: () => showProductPicker(context, disableOutOfStock: true, onSelected: (p) {
                              cart.addProduct(p);
                              _announce('productAdded');
                            }),
                        icon: const Icon(Icons.add),
                        label: const Text('Add More Products'),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.card),
                  TotalsBlock(
                    subtotal: cart.subtotal,
                    taxTotal: cart.taxTotal,
                    deliveryCharge: cart.deliveryCharge,
                    onDeliveryChanged: cart.setDeliveryCharge,
                    grandTotal: cart.grandTotal,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  PaymentTypeSection(
                    allowCredit: cart.saleType == 'customer',
                    paymentMode: cart.paymentMode,
                    onPaymentModeChanged: cart.setPaymentMode,
                    remarks: cart.remarks,
                    onRemarksChanged: cart.setRemarks,
                    paymentReference: cart.paymentReference,
                    onPaymentReferenceChanged: cart.setPaymentReference,
                    paymentNote: cart.paymentNote,
                    onPaymentNoteChanged: cart.setPaymentNote,
                  ),
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
                      cart.clear();
                      _announce('cartClearedSell');
                    },
              style: AppButtonStyles.filled(AppColors.danger),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: ElevatedButton(
              onPressed: (cart.isEmpty || _isSubmitting) ? null : _checkout,
              style: AppButtonStyles.filled(AppColors.success),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Generate VAT Bill'),
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
          color: AppColors.dangerTint,
          borderRadius: BorderRadius.circular(AppRadius.section),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_down, color: AppColors.dangerDark),
                SizedBox(width: AppSpacing.field),
                Text('Sales Return', style: AppTextStyles.subsectionTitle),
              ],
            ),
            const SizedBox(height: AppSpacing.item),
            const Text('Customer (optional)', style: AppTextStyles.label),
            const SizedBox(height: 4),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _returnCustomerId,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Walk-in / No customer')),
                ...data.customers.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (value) => setState(() => _returnCustomerId = value),
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
              icon: Icons.trending_down,
              title: 'Return Items',
              itemCount: _returnItems.length,
              total: _returnGrandTotal,
              background: AppColors.dangerDark,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _returnItems.isEmpty
                      ? EmptyState(
                          icon: Icons.assignment_return_outlined,
                          title: 'No items selected',
                          subtitle: 'Select products to return',
                          action: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            ),
                            onPressed: () => showProductPicker(context, onSelected: (p) => setState(() => _returnItems.add(SaleCartItem(product: p)))),
                            child: const Text('Add Products'),
                          ),
                        )
                      : Column(
                          children: List.generate(_returnItems.length, (index) {
                            final item = _returnItems[index];
                            return CartLineTile(
                              name: item.product.name,
                              category: item.product.category,
                              qty: item.qty,
                              rate: item.rate,
                              lineTotal: item.lineTotal,
                              onIncrement: () => setState(() => item.qty += 1),
                              onDecrement: () => setState(() => item.qty = item.qty > 1 ? item.qty - 1 : 1),
                              onQtyChanged: (v) => setState(() => item.qty = v),
                              onRateChanged: (v) => setState(() => item.rate = v),
                              onRemove: () => setState(() => _returnItems.removeAt(index)),
                            );
                          }),
                        ),
                  if (_returnItems.isNotEmpty) const SizedBox(height: AppSpacing.card),
                  if (_returnItems.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                        onPressed: () => showProductPicker(context, onSelected: (p) => setState(() => _returnItems.add(SaleCartItem(product: p)))),
                        icon: const Icon(Icons.add),
                        label: const Text('Add More Products'),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.card),
                  TotalsBlock(
                    subtotal: _returnSubtotal,
                    taxTotal: _returnTaxTotal,
                    grandTotal: _returnGrandTotal,
                    totalLabel: 'Total Return',
                  ),
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
                        _returnCustomerId = null;
                      }),
              style: AppButtonStyles.filled(AppColors.danger),
              child: const Text('Clear Return'),
            ),
          ),
          const SizedBox(width: AppSpacing.field),
          Expanded(
            child: ElevatedButton(
              onPressed: (_returnItems.isEmpty || _isSubmitting) ? null : _submitReturn,
              style: AppButtonStyles.filled(AppColors.dangerDark),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Post Sales Return'),
            ),
          ),
        ],
      ),
    ];
  }
}

/// Inline "Customer Information" section — mirrors `PosTerminal.jsx`'s
/// customer form exactly: it lives directly in the sale form (no dialog,
/// no Cancel/confirm buttons), with an existing-customer dropdown plus
/// walk-in fields that auto-create a customer when the bill is generated.
class _CustomerInfoSection extends StatelessWidget {
  final List<Party> customers;
  final Party? selectedCustomer;
  final ValueChanged<Party?> onCustomerSelected;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController vatController;
  final TextEditingController addressController;

  const _CustomerInfoSection({
    required this.customers,
    required this.selectedCustomer,
    required this.onCustomerSelected,
    required this.nameController,
    required this.phoneController,
    required this.vatController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.card),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.section),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.field),
              Text('Customer Information', style: AppTextStyles.subsectionTitle),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          DropdownButtonFormField<Party?>(
            isExpanded: true,
            initialValue: selectedCustomer,
            decoration: const InputDecoration(labelText: 'Existing Customer'),
            items: [
              const DropdownMenuItem<Party?>(value: null, child: Text('Select customer')),
              ...customers.map((c) => DropdownMenuItem<Party?>(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis))),
            ],
            onChanged: onCustomerSelected,
          ),
          const SizedBox(height: AppSpacing.field),
          const Row(
            children: [
              Icon(Icons.person_add_alt, size: 16, color: AppColors.textMuted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Leave this blank and enter details below to auto-create a new customer when generating the bill.',
                  style: AppTextStyles.helper,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          TextField(
            controller: nameController,
            enabled: selectedCustomer == null,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: AppSpacing.item),
          TextField(
            controller: phoneController,
            enabled: selectedCustomer == null,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
          const SizedBox(height: AppSpacing.item),
          TextField(
            controller: vatController,
            enabled: selectedCustomer == null,
            decoration: const InputDecoration(labelText: 'VAT Number'),
          ),
          const SizedBox(height: AppSpacing.item),
          TextField(
            controller: addressController,
            enabled: selectedCustomer == null,
            decoration: const InputDecoration(labelText: 'Delivery Address'),
          ),
        ],
      ),
    );
  }
}
