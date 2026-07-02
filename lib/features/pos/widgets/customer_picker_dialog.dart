import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/party.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
import '../services/pos_service.dart';

/// Result of the customer picker: either an existing customer id, or the
/// walk-in-creation fields to send inline with the sale (`customer_name` etc).
class CustomerSelection {
  final int? customerId;
  final String? name;
  final String? phone;
  final String? address;

  CustomerSelection.existing(int id) : customerId = id, name = null, phone = null, address = null;
  CustomerSelection.walkIn({this.name, this.phone, this.address}) : customerId = null;
}

/// Mirrors the customer section of `PosTerminal.jsx`: pick an existing
/// customer, or fill Full Name / Phone / VAT / Address to create one inline.
Future<CustomerSelection?> showCustomerPicker(BuildContext context) {
  return showDialog<CustomerSelection>(
    context: context,
    builder: (_) => const _CustomerPickerDialog(),
  );
}

class _CustomerPickerDialog extends StatefulWidget {
  const _CustomerPickerDialog();

  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  Party? _selectedExisting;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vatController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vatController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createAndSelect() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Full name is required.');
      return;
    }
    final vatNumber = _vatController.text.trim();
    if (vatNumber.isNotEmpty && !RegExp(r'^[A-Za-z0-9]{10}$').hasMatch(vatNumber)) {
      setState(() => _error = 'VAT number must be exactly 10 alphanumeric characters.');
      return;
    }
    final config = context.read<PosConfigProvider>();
    setState(() {
      _isCreating = true;
      _error = null;
    });
    try {
      final service = context.read<PosService>();
      final party = await service.createCustomer(
        companyId: config.selectedCompanyId!,
        name: name,
        mobileNo: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        panVatNo: vatNumber,
      );
      if (!mounted) return;
      context.read<PosDataProvider>().addCustomer(party);
      Navigator.of(context).pop(CustomerSelection.existing(party.id));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<PosDataProvider>();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.section),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(Icons.person_outline, color: AppColors.textSecondary),
                    SizedBox(width: AppSpacing.field),
                    Text('Customer', style: AppTextStyles.subsectionTitle),
                  ],
                ),
                const SizedBox(height: AppSpacing.card),
                DropdownButtonFormField<Party>(
                  isExpanded: true,
                  initialValue: _selectedExisting,
                  decoration: const InputDecoration(labelText: 'Existing Customer'),
                  items: data.customers
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedExisting = value),
                ),
                const SizedBox(height: AppSpacing.item),
                Row(
                  children: const [
                    Icon(Icons.person_add_alt, size: 14, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Or create a new walk-in customer below', style: AppTextStyles.helper),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.item),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: AppSpacing.item),
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                const SizedBox(height: AppSpacing.item),
                TextField(controller: _vatController, decoration: const InputDecoration(labelText: 'VAT Number')),
                const SizedBox(height: AppSpacing.item),
                TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Delivery Address')),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.item),
                  Text(_error!, style: const TextStyle(color: AppColors.dangerDark, fontSize: 12)),
                ],
                const SizedBox(height: AppSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.field),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating
                            ? null
                            : () {
                                if (_selectedExisting != null) {
                                  Navigator.of(context).pop(CustomerSelection.existing(_selectedExisting!.id));
                                } else {
                                  _createAndSelect();
                                }
                              },
                        child: _isCreating
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Use Customer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
