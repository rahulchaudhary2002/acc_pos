import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'pos_audio_settings';

/// Mirrors `PosTerminal.jsx`'s `announcePosMessage`/`announcePosAction`: a
/// thin `speechSynthesis` wrapper gated by user-configurable enabled/
/// language/volume settings, persisted the same way (there it's
/// `localStorage["pos-audio-settings"]`; here it's `SharedPreferences` under
/// the same key/shape) so the toggle behaves identically across platforms.
class VoiceAnnouncer extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool enabled = true;
  String language = 'en'; // 'en' | 'ne'
  double volume = 0.9;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        enabled = map['enabled'] as bool? ?? enabled;
        language = map['language'] as String? ?? language;
        volume = (map['volume'] as num?)?.toDouble() ?? volume;
      } catch (_) {
        // Corrupt/old-shape prefs — fall back to defaults rather than crash.
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode({'enabled': enabled, 'language': language, 'volume': volume}));
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setVolume(double value) async {
    volume = value;
    notifyListeners();
    await _persist();
  }

  Future<void> _speak(String message) async {
    if (!enabled || message.isEmpty) return;
    await _tts.stop();
    await _tts.setLanguage(language == 'ne' ? 'ne-NP' : 'en-US');
    await _tts.setVolume(volume.clamp(0, 1));
    await _tts.speak(message);
  }

  // Spoken on Sell/Buy/Reports/Others tab switches — matches
  // `moduleVoiceLabels` in PosTerminal.jsx exactly.
  static const _moduleLabels = {
    'sell': {'en': 'Switched to Sell', 'ne': 'बिक्री मोडमा परिवर्तन भयो'},
    'buy': {'en': 'Switched to Purchase', 'ne': 'खरिद मोडमा परिवर्तन भयो'},
    'reports': {'en': 'Switched to Reports', 'ne': 'रिपोर्ट मोडमा परिवर्तन भयो'},
    'others': {'en': 'Switched to Settings', 'ne': 'सेटिङ मोडमा परिवर्तन भयो'},
  };

  // Subset of `actionVoiceLabels` in PosTerminal.jsx covering this app's
  // real actions (cart/sale/purchase mutations) — the web's finer-grained
  // events (product-tab switches, picker open/close) have no Flutter
  // equivalent worth wiring separately.
  static const _actionLabels = {
    'saleTypeCash': {'en': 'Switched to cash sale', 'ne': 'नगद बिक्रीमा परिवर्तन भयो'},
    'saleTypeCustomer': {'en': 'Switched to customer sale', 'ne': 'ग्राहक बिक्रीमा परिवर्तन भयो'},
    'productAdded': {'en': 'Product added', 'ne': 'सामान थपियो'},
    'productRemoved': {'en': 'Product removed', 'ne': 'सामान हटाइयो'},
    'cartClearedSell': {'en': 'Current sale cleared', 'ne': 'बिक्री खाली गरियो'},
    'cartClearedBuy': {'en': 'Purchase cleared', 'ne': 'खरिद खाली गरियो'},
    'saleCompleted': {'en': 'Sale completed successfully', 'ne': 'बिक्री सफलतापूर्वक सम्पन्न भयो'},
    'purchaseCompleted': {'en': 'Purchase saved successfully', 'ne': 'खरिद सफलतापूर्वक सुरक्षित भयो'},
  };

  Future<void> announceModule(String tabKey) => _speak(_moduleLabels[tabKey]?[language] ?? _moduleLabels[tabKey]?['en'] ?? '');

  Future<void> announceAction(String key) => _speak(_actionLabels[key]?[language] ?? _actionLabels[key]?['en'] ?? '');

  // Mirrors `previewAudioPrompt` — a fixed sentence, independent of any
  // action/module label, spoken by the "Test Voice Prompt" button.
  Future<void> preview() => _speak(language == 'ne' ? 'पी ओ एस ध्वनि सूचना सफलतापूर्वक सक्रिय भयो' : 'POS voice prompt is enabled');
}
