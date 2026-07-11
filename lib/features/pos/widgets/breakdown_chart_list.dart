import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/breakdown_row.dart';

/// Horizontal bar chart + ranked list for a "-wise" breakdown report
/// (store-wise / vendor-wise / customer-wise).
class BreakdownChartList extends StatelessWidget {
  final List<BreakdownRow> rows;
  final String Function(BreakdownRow) nameOf;
  final double Function(BreakdownRow) valueOf;
  final Color color;
  final String? emptyMessage;

  const BreakdownChartList({
    super.key,
    required this.rows,
    required this.nameOf,
    required this.valueOf,
    this.color = AppColors.info,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            emptyMessage ?? AppLocalizations.of(context)!.breakdownChartListNoDataMessage,
            style: AppTextStyles.helper,
          ),
        ),
      );
    }

    final top = rows.take(5).toList();
    final maxValue = top.map(valueOf).fold<double>(0, (acc, v) => v > acc ? v : acc);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue * 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: safeMax,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeMax / 4,
                getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: safeMax / 4,
                    getTitlesWidget: (value, meta) => Text(
                      value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                      style: AppTextStyles.tiny,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= top.length) return const SizedBox.shrink();
                      final name = nameOf(top[i]);
                      final short = name.length > 10 ? '${name.substring(0, 9)}…' : name;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(short, style: AppTextStyles.tiny, textAlign: TextAlign.center),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    '${nameOf(top[group.x.toInt()])}\nNPR ${rod.toY.toStringAsFixed(0)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < top.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: valueOf(top[i]), color: color, width: 22, borderRadius: BorderRadius.circular(4)),
                  ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.card),
        ...rows.map((row) => _rowTile(context, row)),
      ],
    );
  }

  Widget _rowTile(BuildContext context, BreakdownRow row) {
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
                Text(nameOf(row), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                if (row.panVatNo != null && row.panVatNo!.isNotEmpty)
                  Text(
                    AppLocalizations.of(context)!.breakdownChartListVatLabel(row.panVatNo!),
                    style: AppTextStyles.tiny,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('NPR ${valueOf(row).toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              Text(
                AppLocalizations.of(context)!.breakdownChartListTransactionsCount(row.count),
                style: AppTextStyles.tiny,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
