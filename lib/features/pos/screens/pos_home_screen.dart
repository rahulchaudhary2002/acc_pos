import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:acc_pos/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
import '../providers/voice_announcer.dart';
import 'buy_screen.dart';
import 'others_screen.dart';
import 'reports_screen.dart';
import 'sell_screen.dart';

/// Tab shell mirroring `PosTerminal.jsx`'s bottom navigation: Sell / Buy /
/// Reports / Others. Full-bleed on mobile — no outer margin/max-width, since
/// a native app fills the screen rather than floating a centered web card.
class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key});

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  int _tabIndex = 0;
  bool _initialized = false;

  static const _tabKeys = ['sell', 'buy', 'reports', 'others'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Defer past the current build phase — PosConfigProvider.load() calls
      // notifyListeners() before its first await, which throws if triggered
      // synchronously from didChangeDependencies during initial mount.
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapPosData());
    }
  }

  Future<void> _bootstrapPosData() async {
    final config = context.read<PosConfigProvider>();
    await config.load();
    if (!mounted) return;
    if (config.isReady) {
      await context.read<PosDataProvider>().loadProducts(
            companyId: config.selectedCompanyId,
            outletId: config.selectedOutletId,
            locationId: config.selectedLocationId,
          );
      if (!mounted) return;
      await context.read<PosDataProvider>().loadParties(companyId: config.selectedCompanyId);
    }
  }

  Future<void> _reloadForSelection() async {
    final config = context.read<PosConfigProvider>();
    if (!config.isReady) return;
    final data = context.read<PosDataProvider>();
    await data.loadProducts(
      companyId: config.selectedCompanyId,
      outletId: config.selectedOutletId,
      locationId: config.selectedLocationId,
    );
    if (!mounted) return;
    await data.loadParties(companyId: config.selectedCompanyId);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<PosConfigProvider>();

    // The gradient is the page backdrop — individual sections (cards) get
    // their own white background, not the whole body. Full-bleed just means
    // no outer margin/rounded-card wrapper around all of it on mobile.
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientMid, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: config.isLoading
              ? const Center(child: CircularProgressIndicator())
              : config.needsCompanyPicker
                  ? _CompanyPicker(onSelected: () => _reloadForSelection())
                  : Column(
                      children: [
                        Expanded(child: _buildTab()),
                        _BottomNav(
                          index: _tabIndex,
                          onChanged: (i) {
                            setState(() => _tabIndex = i);
                            context.read<VoiceAnnouncer>().announceModule(_tabKeys[i]);
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 1:
        return const BuyScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const OthersScreen();
      default:
        return const SellScreen();
    }
  }
}

class _CompanyPicker extends StatelessWidget {
  final VoidCallback onSelected;

  const _CompanyPicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<PosConfigProvider>();
    // The company list is server-driven and can run into the dozens
    // (production has 16+), so it must scroll rather than size to content —
    // a fixed-height Column overflowed once there were more companies than
    // fit on screen.
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context)!.posHomeSelectCompanyLabel, style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.card),
          Expanded(
            child: ListView.builder(
              itemCount: config.companies.length,
              itemBuilder: (context, index) {
                final c = config.companies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.field),
                  child: ListTile(
                    title: Text(c.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      config.selectCompany(c.id);
                      onSelected();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Light "white/95" bar with a rounded top and a `sky-50` pill behind the
/// active tab — matches `PosTerminal.jsx`'s bottom nav (line ~5356).
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      (Icons.shopping_cart, l10n.posHomeBottomNavSellLabel),
      (Icons.shopping_bag, l10n.posHomeBottomNavBuyLabel),
      (Icons.bar_chart, l10n.posHomeBottomNavReportsLabel),
      (Icons.settings, l10n.posHomeBottomNavOthersLabel),
    ];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.field, horizontal: AppSpacing.tight),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = i == index;
          final (icon, label) = tabs[i];
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(AppRadius.control),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.infoTint : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: selected ? AppColors.info : AppColors.textMuted, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.info : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
