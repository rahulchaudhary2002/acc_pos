import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/payment_mode_stat.dart';

const _modeColors = {
  'cash': AppColors.success,
  'credit': AppColors.warningDark,
  'online': AppColors.info,
};

Color _colorFor(String mode) => _modeColors[mode] ?? AppColors.textFaint;

/// Pie chart of sales split by payment mode (cash / credit / online).
class PaymentModePieChart extends StatelessWidget {
  final List<PaymentModeStat> stats;

  const PaymentModePieChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.paymentModePieChartNoSalesMessage,
            style: AppTextStyles.helper,
          ),
        ),
      );
    }

    final total = stats.fold<double>(0, (acc, s) => acc + s.total);

    return Row(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: stats.map((s) {
                final pct = total <= 0 ? 0 : (s.total / total) * 100;
                return PieChartSectionData(
                  value: s.total <= 0 ? 0.001 : s.total,
                  color: _colorFor(s.mode),
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 36,
                  titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.card),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: _colorFor(s.mode), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${s.mode[0].toUpperCase()}${s.mode.substring(1)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    Text('NPR ${s.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
