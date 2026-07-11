import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/date_locale_provider.dart';

/// Header bar shared by every POS tab: icon circle + title + subtitle on the
/// left, a live clock/date pill on the right — mirrors `PosTerminal.jsx`'s
/// header (`#284457` bar, `#19a7e0` icon circle, `rounded-t-[32px]`). The
/// pill is tappable, offering English (Gregorian) or Nepali (Bikram Sambat)
/// date display — a POS-terminal convenience with no direct web equivalent.
class PosScreenHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PosScreenHeader({super.key, required this.title, required this.subtitle, this.icon = Icons.local_gas_station});

  @override
  State<PosScreenHeader> createState() => _PosScreenHeaderState();
}

class _PosScreenHeaderState extends State<PosScreenHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLocale = context.watch<DateLocaleProvider>();
    final isNepali = dateLocale.language == 'ne';

    String timeLabel;
    String dateLabel;
    if (isNepali) {
      final npNow = _now.toNepaliDateTime();
      timeLabel = NepaliDateFormat.jm(Language.nepali).format(npNow);
      dateLabel = NepaliDateFormat.yMMMMd(Language.nepali).format(npNow);
    } else {
      // Explicit 'en_US' locale — otherwise intl falls back to the device's
      // system locale, which renders Nepali digits/month names here too on
      // a phone set to Nepali, defeating the English option entirely.
      timeLabel = DateFormat('h:mm a', 'en_US').format(_now);
      dateLabel = DateFormat('MMM d, yyyy', 'en_US').format(_now);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.card, vertical: AppSpacing.card),
      decoration: const BoxDecoration(color: AppColors.headerDark),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: AppColors.headerIconCircle, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.card),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.pageTitle),
                const SizedBox(height: 4),
                Text(widget.subtitle, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => context.read<DateLocaleProvider>().setLanguage(value),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(value: 'en', checked: !isNepali, child: Text(AppLocalizations.of(context)!.posScreenHeaderLanguageEnglish)),
              CheckedPopupMenuItem(value: 'ne', checked: isNepali, child: Text(AppLocalizations.of(context)!.posScreenHeaderLanguageNepali)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeLabel, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.textOnDarkMuted),
                      const SizedBox(width: 4),
                      Text(dateLabel, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
