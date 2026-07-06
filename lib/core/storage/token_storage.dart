import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum bearer token and cached user/session bits across launches.
class TokenStorage {
  static const _tokenKey = 'pos_token';
  static const _userIdKey = 'pos_user_id';
  static const _userNameKey = 'pos_user_name';
  static const _userEmailKey = 'pos_user_email';
  static const _companyIdKey = 'pos_company_id';
  static const _outletIdKey = 'pos_outlet_id';
  static const _locationIdKey = 'pos_location_id';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Reads a key, treating undecryptable storage as absent. When the app is
  /// reinstalled (or the Android Keystore key is otherwise lost), the old
  /// encrypted prefs survive but can no longer be decrypted — secure_storage
  /// then throws a PlatformException (BadPaddingException/BAD_DECRYPT) that
  /// would otherwise kill bootstrap() and leave the app stuck on the splash
  /// spinner. Wipe the orphaned data and report "no session" instead.
  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException {
      try {
        await _storage.deleteAll();
      } catch (_) {}
      return null;
    }
  }

  Future<String?> readToken() => _read(_tokenKey);

  Future<void> saveSession({
    required String token,
    required int userId,
    required String userName,
    required String userEmail,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _userNameKey, value: userName);
    await _storage.write(key: _userEmailKey, value: userEmail);
  }

  Future<Map<String, String>?> readCachedUser() async {
    final id = await _read(_userIdKey);
    final name = await _read(_userNameKey);
    final email = await _read(_userEmailKey);
    if (id == null || name == null || email == null) return null;
    return {'id': id, 'name': name, 'email': email};
  }

  Future<void> saveSelection({int? companyId, int? outletId, int? locationId}) async {
    if (companyId != null) {
      await _storage.write(key: _companyIdKey, value: companyId.toString());
    }
    if (outletId != null) {
      await _storage.write(key: _outletIdKey, value: outletId.toString());
    }
    if (locationId != null) {
      await _storage.write(key: _locationIdKey, value: locationId.toString());
    }
  }

  Future<Map<String, int?>> readSelection() async {
    final companyId = await _read(_companyIdKey);
    final outletId = await _read(_outletIdKey);
    final locationId = await _read(_locationIdKey);
    return {
      'companyId': companyId != null ? int.tryParse(companyId) : null,
      'outletId': outletId != null ? int.tryParse(outletId) : null,
      'locationId': locationId != null ? int.tryParse(locationId) : null,
    };
  }

  Future<void> clear() => _storage.deleteAll();
}
