import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/trend_point.dart';

/// Line chart of daily sales vs. purchases, backed by `GET /pos/reports/daily-trend`.
class SalesTrendChart extends StatelessWidget {
  final List<TrendPoint> points;

  const SalesTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data for this period', style: AppTextStyles.helper)),
      );
    }

    final maxY = points
        .expand((p) => [p.totalSales, p.totalPurchases])
        .fold<double>(0, (acc, v) => v > acc ? v : acc);
    final safeMaxY = maxY <= 0 ? 1.0 : maxY * 1.15;
    final step = points.length > 8 ? (points.length / 4).ceil() : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legendDot(AppColors.success, 'Sales'),
            const SizedBox(width: AppSpacing.card),
            _legendDot(AppColors.warningDark, 'Purchases'),
          ],
        ),
        const SizedBox(height: AppSpacing.item),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: safeMaxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeMaxY / 4,
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
                    interval: safeMaxY / 4,
                    getTitlesWidget: (value, meta) => Text(
                      value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                      style: AppTextStyles.tiny,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: step.toDouble(),
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= points.length) return const SizedBox.shrink();
                      final date = DateTime.tryParse(points[i].date);
                      final label = date == null ? '' : DateFormat('d MMM').format(date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(label, style: AppTextStyles.tiny),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    final i = s.x.toInt();
                    final date = i >= 0 && i < points.length ? points[i].date : '';
                    final color = s.barIndex == 0 ? AppColors.success : AppColors.warningDark;
                    return LineTooltipItem(
                      '$date\nRs ${s.y.toStringAsFixed(0)}',
                      TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                _line(points.map((p) => p.totalSales).toList(), AppColors.success),
                _line(points.map((p) => p.totalPurchases).toList(), AppColors.warningDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData _line(List<double> values, Color color) {
    return LineChartBarData(
      spots: [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])],
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.helper),
      ],
    );
  }
}
