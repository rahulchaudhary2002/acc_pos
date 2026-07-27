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

  const RecentTransactionsList({super.key, required this.items, this.color = AppColors.info, this.emptyMessage, this.limit = 10});

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
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.field),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.field),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.documentNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
            ],
          ),
        );
      }).toList(),
    );
  }
}
