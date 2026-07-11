import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'app_locale';

/// Controls the app-wide UI locale (English/Nepali) used by flutter's
/// generated AppLocalizations. `locale == null` means "follow the system
/// locale, restricted to the locales this app supports".
class LocaleProvider extends ChangeNotifier {
  Locale? locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'en' || saved == 'ne') {
      locale = Locale(saved!);
    } else {
      final platformLanguageCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      locale = Locale(platformLanguageCode == 'ne' ? 'ne' : 'en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    this.locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
