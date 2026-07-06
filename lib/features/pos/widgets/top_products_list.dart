import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/top_product.dart';

/// Horizontal bar chart + ranked list of best-selling products by revenue.
class TopProductsList extends StatelessWidget {
  final List<TopProduct> products;

  const TopProductsList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('No sales for this period', style: AppTextStyles.helper)),
      );
    }

    final top = products.take(5).toList();
    final maxValue = top.map((p) => p.revenue).fold<double>(0, (acc, v) => v > acc ? v : acc);
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
                      final name = top[i].name;
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
                    '${top[group.x.toInt()].name}\nRs ${rod.toY.toStringAsFixed(0)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < top.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: top[i].revenue, color: AppColors.share, width: 22, borderRadius: BorderRadius.circular(4)),
                  ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.card),
        ...products.map((p) => Container(
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
                        Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        Text('${p.qty.toStringAsFixed(p.qty % 1 == 0 ? 0 : 2)} ${p.unit}', style: AppTextStyles.tiny),
                      ],
                    ),
                  ),
                  Text('Rs ${p.revenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.share)),
                ],
              ),
            )),
      ],
    );
  }
}
