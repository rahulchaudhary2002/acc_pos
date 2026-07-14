import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/buy_cart_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/pos_config_provider.dart';
import '../providers/pos_data_provider.dart';
import '../providers/voice_announcer.dart';
import '../widgets/pos_screen_header.dart';
import '../widgets/printer_settings_card.dart';

/// Others/Settings tab: POS configuration switcher (company/outlet/fiscal
/// year/warehouse), the POS Voice Prompt announcer settings, logout, and
/// reset — all fully functional, mirroring `PosTerminal.jsx`'s Others tab.
class OthersScreen extends StatefulWidget {
  const OthersScreen({super.key});

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen> {
  bool _isResetting = false;
  String? _error;

  Future<void> _logout() async {
    // Regardless of what the logout API call returns (success, error, or a
    // network failure), the local session, cached workspace/product data,
    // and both carts must all clear and the app must return to the login
    // screen — never leave the user looking at stale data for an account
    // they're no longer signed into.
    final auth = context.read<AuthProvider>();
    final config = context.read<PosConfigProvider>();
    final data = context.read<PosDataProvider>();
    final cart = context.read<CartProvider>();
    final buyCart = context.read<BuyCartProvider>();
    await auth.logout();
    config.reset();
    data.reset();
    cart.clear();
    buyCart.clear();
  }

  // Mirrors PosTerminal.jsx: changing company/outlet/warehouse there
  // reactively refetches products/prices/parties for the new workspace via
  // effects keyed on those ids. Flutter has no equivalent reactive effect,
  // so each POS Configuration dropdown explicitly triggers this after
  // updating the selection — otherwise the product list and stock figures
  // silently kept showing data for the outlet/warehouse picked before.
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

  Future<void> _resetSystem() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.othersScreenResetSystemDialogTitle),
        content: Text(l10n.othersScreenResetSystemDialogContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.othersScreenCancelButton)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.othersScreenResetButton)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isResetting = true;
      _error = null;
    });
    final config = context.read<PosConfigProvider>();
    final data = context.read<PosDataProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await config.load();
      await data.loadProducts(
        companyId: config.selectedCompanyId,
        outletId: config.selectedOutletId,
        locationId: config.selectedLocationId,
      );
      await data.loadParties(companyId: config.selectedCompanyId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.othersScreenRefreshSuccessMessage)),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<PosConfigProvider>();
    final isLoggingOut = context.watch<AuthProvider>().isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        PosScreenHeader(title: l10n.othersScreenTitle, subtitle: l10n.othersScreenSubtitle, icon: Icons.settings),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ErrorBanner(message: _error!, onDismiss: () => setState(() => _error = null)),
                Container(
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
                          const Icon(Icons.build_outlined, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.field),
                          Text(l10n.othersScreenPosConfigurationHeader, style: AppTextStyles.cardHeader),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.card),
                      Row(
                        children: [
                          Expanded(
                            child: _configField(
                              label: l10n.othersScreenCompanyLabel,
                              // Mirrors PosTerminal.jsx: always a <select>,
                              // never collapsed to read-only text even with
                              // one option — the web app never does that.
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: config.selectedCompanyId,
                                items: config.companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (id) {
                                  if (id == null) return;
                                  config.selectCompany(id);
                                  _reloadForSelection();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.item),
                          Expanded(
                            child: _configField(
                              label: l10n.othersScreenOutletLabel,
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: config.selectedOutletId,
                                items: config.outletsForSelectedCompany().map((o) => DropdownMenuItem(value: o.id, child: Text(o.name, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (id) {
                                  if (id == null) return;
                                  config.selectOutlet(id);
                                  _reloadForSelection();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.item),
                      Row(
                        children: [
                          Expanded(
                            child: _configField(
                              label: l10n.othersScreenFiscalYearLabel,
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: config.selectedFiscalYearId,
                                items: config.fiscalYearsForSelectedCompany().map((f) => DropdownMenuItem(value: f.id, child: Text(f.name, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (id) {
                                  if (id != null) config.selectFiscalYear(id);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.item),
                          Expanded(
                            child: _configField(
                              label: l10n.othersScreenWarehouseLabel,
                              child: DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: config.selectedLocationId,
                                items: config.locationsForSelectedOutlet().map((l) => DropdownMenuItem(value: l.id, child: Text(l.name, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (id) {
                                  if (id == null) return;
                                  config.selectLocation(id);
                                  _reloadForSelection();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.item),
                      _configField(label: l10n.languageCardHeader, child: const _LanguageSwitcher()),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.card),
                const _VoicePromptCard(),
                const SizedBox(height: AppSpacing.card),
                const PrinterSettingsCard(),
                const SizedBox(height: AppSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoggingOut ? null : _logout,
                        style: AppButtonStyles.filled(AppColors.danger),
                        child: isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(l10n.othersScreenLogoutButton),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.item),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isResetting ? null : _resetSystem,
                        style: AppButtonStyles.filled(AppColors.warningDark),
                        child: _isResetting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(l10n.othersScreenResetSystemButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _configField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _VoicePromptCard extends StatelessWidget {
  const _VoicePromptCard();

  @override
  Widget build(BuildContext context) {
    final announcer = context.watch<VoiceAnnouncer>();
    final l10n = AppLocalizations.of(context)!;
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
              const Icon(Icons.settings, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.field),
              Text(l10n.voicePromptCardHeader, style: AppTextStyles.cardHeader),
            ],
          ),
          const SizedBox(height: AppSpacing.card),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.voicePromptSoundStatusLabel, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<bool>(
                      isExpanded: true,
                      initialValue: announcer.enabled,
                      items: [
                        DropdownMenuItem(value: true, child: Text(l10n.voicePromptOnLabel)),
                        DropdownMenuItem(value: false, child: Text(l10n.voicePromptOffLabel)),
                      ],
                      onChanged: (v) => announcer.setEnabled(v ?? true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.item),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.voicePromptAnnouncementLanguageLabel, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: announcer.language,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ne', child: Text('Nepali')),
                      ],
                      onChanged: (v) => announcer.setLanguage(v ?? 'en'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          Text(l10n.voicePromptVolumeLabel, style: AppTextStyles.label),
          Slider(
            value: announcer.volume,
            onChanged: (v) => announcer.setVolume(v),
            activeColor: AppColors.info,
          ),
          Text(
            l10n.voicePromptHelperText,
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: AppSpacing.item),
          Wrap(
            spacing: AppSpacing.field,
            runSpacing: AppSpacing.field,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton(
                onPressed: announcer.preview,
                style: AppButtonStyles.filled(AppColors.info).copyWith(
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
                    ),
                child: Text(l10n.voicePromptTestButton, style: const TextStyle(fontSize: 13)),
              ),
              // Mirrors PosTerminal.jsx's example chip next to the button —
              // shows the phrase a tab switch actually speaks, in whichever
              // language is currently selected.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.item, vertical: AppSpacing.field),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  announcer.language == 'ne' ? 'उदाहरण: खरिद मोडमा परिवर्तन भयो' : 'Example: Switched to Purchase',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.locale;

    Widget languageChip({required String label, required Locale locale}) {
      final isActive = current?.languageCode == locale.languageCode;
      return ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => context.read<LocaleProvider>().setLocale(locale),
        selectedColor: AppColors.info,
        labelStyle: TextStyle(color: isActive ? Colors.white : AppColors.textPrimary),
      );
    }

    return Wrap(
      spacing: AppSpacing.field,
      runSpacing: AppSpacing.field,
      children: [
        languageChip(label: 'English', locale: const Locale('en')),
        languageChip(label: 'नेपाली', locale: const Locale('ne')),
      ],
    );
  }
}
