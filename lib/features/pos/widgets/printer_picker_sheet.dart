import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/printer_provider.dart';
import '../utils/thermal_receipt_builder.dart';

/// Bottom sheet listing the phone's paired Bluetooth printers (MYXprint-style
/// picker). Selecting one saves it as the app's printer and returns it; the
/// same sheet serves Others → Printer Connection and the first "Print Bill"
/// tap when no printer is configured yet.
Future<PrinterDevice?> showPrinterPickerSheet(BuildContext context) {
  return showModalBottomSheet<PrinterDevice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.section)),
    ),
    builder: (_) => const _PrinterPickerSheet(),
  );
}

/// Bottom sheet shown on every "Print" tap, letting the cashier choose
/// between the saved Bluetooth thermal printer and the normal PDF/system
/// print dialog for that one bill, instead of silently deciding based on
/// whether a printer happens to be configured.
Future<void> showPrintMethodSheet(
  BuildContext context, {
  required Future<void> Function() onThermalPrint,
  required Future<void> Function() onPdfPrint,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.section)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.printMethodSheetTitle, style: AppTextStyles.cardHeader, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.card),
            _PrintMethodTile(
              icon: Icons.bluetooth,
              label: l10n.printMethodBluetoothOption,
              hint: l10n.printMethodBluetoothHint,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onThermalPrint();
              },
            ),
            const SizedBox(height: AppSpacing.field),
            _PrintMethodTile(
              icon: Icons.picture_as_pdf_outlined,
              label: l10n.printMethodNormalOption,
              hint: l10n.printMethodNormalHint,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPdfPrint();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _PrintMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _PrintMethodTile({required this.icon, required this.label, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.control),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.item),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.info),
            const SizedBox(width: AppSpacing.item),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

String printerErrorMessage(AppLocalizations l10n, PrinterErrorCode code) {
  switch (code) {
    case PrinterErrorCode.bluetoothOff:
      return l10n.printerErrorBluetoothOff;
    case PrinterErrorCode.permissionDenied:
      return l10n.printerErrorPermissionDenied;
    case PrinterErrorCode.noPrinterSelected:
      return l10n.printerErrorNoPrinterSelected;
    case PrinterErrorCode.connectionFailed:
      return l10n.printerErrorConnectionFailed;
    case PrinterErrorCode.printFailed:
      return l10n.printerErrorPrintFailed;
  }
}

/// One-tap bill printing for the invoice previews: prints [data] (or, when
/// [extraCopies] is given, [data] followed by each extra copy as one
/// continuous print job — e.g. a sales invoice's tax invoice + plain invoice
/// copies) on the saved Bluetooth printer, first opening the picker sheet
/// when no printer is configured yet. Reports progress/success/failure via
/// snackbars.
Future<void> printBillOnThermalPrinter(
  BuildContext context, {
  required ThermalReceiptData data,
  List<ThermalReceiptData> extraCopies = const [],
}) async {
  final printer = context.read<PrinterProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  if (!printer.hasSavedPrinter) {
    final selected = await showPrinterPickerSheet(context);
    if (selected == null) return;
  }
  messenger.showSnackBar(
    SnackBar(content: Text(l10n.printerPrintingMessage), duration: const Duration(seconds: 30)),
  );
  try {
    await printer.printReceipts([data, ...extraCopies]);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(l10n.printerPrintSuccessMessage)));
  } on PrinterException catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(printerErrorMessage(l10n, e.code)), backgroundColor: AppColors.danger),
    );
  }
}

class _PrinterPickerSheet extends StatefulWidget {
  const _PrinterPickerSheet();

  @override
  State<_PrinterPickerSheet> createState() => _PrinterPickerSheetState();
}

class _PrinterPickerSheetState extends State<_PrinterPickerSheet> {
  List<PrinterDevice>? _devices;
  PrinterErrorCode? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devices = await context.read<PrinterProvider>().scanDevices();
      if (!mounted) return;
      setState(() => _devices = devices);
    } on PrinterException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final savedMac = context.watch<PrinterProvider>().savedPrinter?.mac;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.card,
          right: AppSpacing.card,
          top: AppSpacing.card,
          bottom: AppSpacing.card + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.bluetooth, color: AppColors.info),
                const SizedBox(width: AppSpacing.field),
                Expanded(child: Text(l10n.printerPickerTitle, style: AppTextStyles.cardHeader)),
                IconButton(
                  onPressed: _loading ? null : _scan,
                  tooltip: l10n.printerPickerRefreshTooltip,
                  icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.field),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.section),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Text(
                  printerErrorMessage(l10n, _error!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              )
            else if ((_devices ?? []).isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.card),
                child: Text(
                  l10n.printerPickerNoDevicesMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _devices!.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.field),
                  itemBuilder: (context, index) {
                    final device = _devices![index];
                    final isSaved = device.mac == savedMac;
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      onTap: () async {
                        await context.read<PrinterProvider>().selectPrinter(device);
                        if (context.mounted) Navigator.of(context).pop(device);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.item),
                        decoration: BoxDecoration(
                          color: isSaved ? AppColors.infoTint : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.control),
                          border: Border.all(color: isSaved ? AppColors.borderInfoActive : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.print, color: isSaved ? AppColors.info : AppColors.textMuted),
                            const SizedBox(width: AppSpacing.item),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name.isEmpty ? device.mac : device.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                  Text(device.mac, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            if (isSaved) const Icon(Icons.check_circle, color: AppColors.info, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.field),
            Text(
              l10n.printerPickerHelperText,
              textAlign: TextAlign.center,
              style: AppTextStyles.helper,
            ),
          ],
        ),
      ),
    );
  }
}
