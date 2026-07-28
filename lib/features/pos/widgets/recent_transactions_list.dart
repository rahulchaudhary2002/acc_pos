import 'package:flutter/material.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_summary.dart';

/// Simple recent-activity list shared by the sales and purchases sections
/// of the reports "More" tab.
class RecentTransactionsList extends StatelessWidget {
  final List<TransactionSummary> items;
  final Color color;
  final String? emptyMessage;

  /// Caps how many rows render — the Reports "More" tab passes the default
  /// of 10 for a quick preview; a dedicated list screen passes `null` to show
  /// everything.
  final int? limit;

  /// When set, each row gets a trailing print button — used by the Recent
  /// Bills screen to re-print a historical document. Omitted (null) on the
  /// Reports "More" tab, which stays a read-only preview.
  final void Function(TransactionSummary item)? onPrint;

  /// The id of the row currently being fetched/printed, so its print button
  /// can show a spinner instead of the icon while [onPrint] is in flight.
  final int? printingId;

  /// When set, each row gets a trailing cancel button — used by the Recent
  /// Bills screen to cancel a posted purchase bill/sales invoice (reversing
  /// its stock movement and linked journal entries server-side). Omitted
  /// (null) on the Reports "More" tab, which stays a read-only preview.
  final void Function(TransactionSummary item)? onCancel;

  /// The id of the row currently being cancelled, so its cancel button can
  /// show a spinner instead of the icon while [onCancel] is in flight.
  final int? cancellingId;

  const RecentTransactionsList({
    super.key,
    required this.items,
    this.color = AppColors.info,
    this.emptyMessage,
    this.limit = 10,
    this.onPrint,
    this.printingId,
    this.onCancel,
    this.cancellingId,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(emptyMessage ?? AppLocalizations.of(context)!.recentTransactionsEmptyMessage, style: AppTextStyles.helper)),
      );
    }

    final visibleItems = limit == null ? items : items.take(limit!);
    return Column(
      children: visibleItems.map((t) {
        final isCancelled = t.status == 'cancelled';
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.field),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.field),
          decoration: BoxDecoration(
            color: isCancelled ? AppColors.danger.withValues(alpha: 0.06) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: isCancelled ? AppColors.danger.withValues(alpha: 0.3) : AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.documentNo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCancelled ? AppColors.textMuted : AppColors.textSecondary,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (isCancelled) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.recentBillsScreenCancelledBadge,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text('${t.partyName ?? '-'} · ${t.date}', style: AppTextStyles.tiny),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('NPR ${t.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                  if (t.subtitle.isNotEmpty) Text(t.subtitle, style: AppTextStyles.tiny),
                ],
              ),
              if (onPrint != null || (onCancel != null && !isCancelled)) const SizedBox(width: 4),
              if (onPrint != null)
                printingId == t.id
                    ? const SizedBox(height: 32, width: 32, child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(
                        onPressed: () => onPrint!(t),
                        icon: Icon(Icons.print, size: 20, color: color),
                        tooltip: 'Print',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
              if (onPrint != null && onCancel != null && !isCancelled) const SizedBox(width: 2),
              if (onCancel != null && !isCancelled)
                cancellingId == t.id
                    ? const SizedBox(height: 32, width: 32, child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(strokeWidth: 2)))
                    : IconButton(
                        onPressed: () => onCancel!(t),
                        icon: const Icon(Icons.cancel_outlined, size: 20, color: AppColors.danger),
                        tooltip: AppLocalizations.of(context)!.recentBillsScreenCancelTooltip,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
