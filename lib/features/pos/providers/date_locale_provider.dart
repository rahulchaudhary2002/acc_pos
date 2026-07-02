import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'pos_date_language';

/// Controls whether the header clock/date pill (shared by every POS screen)
/// displays the Gregorian date in English or the Bikram Sambat date in
/// Nepali. Lives in a provider rather than per-header widget state so the
/// choice is shared and persists across tab switches and app restarts.
class DateLocaleProvider extends ChangeNotifier {
  String language = 'en'; // 'en' | 'ne'

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString(_prefsKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value);
  }
}
