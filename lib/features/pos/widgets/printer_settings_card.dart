import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/printer_provider.dart';
import 'printer_picker_sheet.dart';

/// Others-tab "Printer Connection" card: pick a paired Bluetooth thermal
/// printer once (MYXprint-style), choose the paper width, and fire a test
/// print — the saved printer is then used by the invoice previews' "Print
/// Bill" action.
class PrinterSettingsCard extends StatelessWidget {
  const PrinterSettingsCard({super.key});

  Future<void> _testPrint(BuildContext context) async {
    final printer = context.read<PrinterProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    try {
      await printer.testPrint();
      messenger.showSnackBar(SnackBar(content: Text(l10n.printerTestPrintSentMessage)));
    } on PrinterException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(printerErrorMessage(l10n, e.code)), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = context.watch<PrinterProvider>();
    final l10n = AppLocalizations.of(context)!;
    final saved = printer.savedPrinter;

    return Container(
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
              const Icon(Icons.print_outlined, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.field),
              Text(l10n.printerCardHeader, style: AppTextStyles.cardHeader),
            ],
          ),
          const SizedBox(height: AppSpacing.card),
          Container(
            padding: const EdgeInsets.all(AppSpacing.item),
            decoration: BoxDecoration(
              color: saved != null ? AppColors.infoTint : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: Border.all(color: saved != null ? AppColors.borderInfo : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  saved != null ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: saved != null ? AppColors.info : AppColors.textFaint,
                ),
                const SizedBox(width: AppSpacing.item),
                Expanded(
                  child: saved != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saved.name.isEmpty ? saved.mac : saved.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            Text(saved.mac, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        )
                      : Text(
                          l10n.printerCardNoPrinterMessage,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                ),
                if (saved != null)
                  IconButton(
                    onPressed: printer.isPrinting ? null : () => context.read<PrinterProvider>().forgetPrinter(),
                    tooltip: l10n.printerCardForgetTooltip,
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.item),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.printerCardPaperSizeLabel, style: AppTextStyles.label),
              const SizedBox(height: 4),
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: printer.paperWidthMm,
                items: [
                  DropdownMenuItem(value: 58, child: Text(l10n.printerCardPaperSize58Label)),
                  DropdownMenuItem(value: 80, child: Text(l10n.printerCardPaperSize80Label)),
                ],
                onChanged: (v) {
                  if (v != null) context.read<PrinterProvider>().setPaperWidth(v);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          Wrap(
            spacing: AppSpacing.field,
            runSpacing: AppSpacing.field,
            children: [
              ElevatedButton.icon(
                onPressed: printer.isPrinting ? null : () => showPrinterPickerSheet(context),
                style: AppButtonStyles.filled(AppColors.info),
                icon: const Icon(Icons.bluetooth_searching, size: 18),
                label: Text(saved != null ? l10n.printerCardChangePrinterButton : l10n.printerCardSelectPrinterButton),
              ),
              ElevatedButton.icon(
                onPressed: saved == null || printer.isPrinting ? null : () => _testPrint(context),
                style: AppButtonStyles.filled(AppColors.success),
                icon: printer.isPrinting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.receipt_long, size: 18),
                label: Text(l10n.printerCardTestPrintButton),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          Text(l10n.printerCardHelperText, style: AppTextStyles.helper),
        ],
      ),
    );
  }
}
