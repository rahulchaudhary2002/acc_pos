import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, unauthenticated, otpRequired, authenticated }

/// Drives the mobile POS auth flow: login -> OTP -> token persisted ->
/// authenticated. Also handles the boot-time "do we already have a token"
/// check and the forced logout triggered by a 401 from any API call.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthProvider({required AuthService authService, required TokenStorage tokenStorage})
      : _authService = authService,
        _tokenStorage = tokenStorage;

  AuthStatus status = AuthStatus.checking;
  AppUser? user;
  int? pendingUserId;
  bool isLoading = false;
  String? errorMessage;
  Map<String, List<String>>? fieldErrors;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final cached = await _tokenStorage.readCachedUser();
    if (cached != null) {
      user = AppUser(
        id: int.parse(cached['id']!),
        name: cached['name']!,
        email: cached['email']!,
      );
    }
    // Optimistically authenticated; a 401 on the first real API call (e.g.
    // /pos/config) will call forceLogout() via the ApiClient interceptor.
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    fieldErrors = null;
    notifyListeners();
    try {
      final result = await _authService.login(email: email, password: password);
      pendingUserId = result.userId;
      status = AuthStatus.otpRequired;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      fieldErrors = e.fieldErrors;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (pendingUserId == null) return false;
    isLoading = true;
    errorMessage = null;
    fieldErrors = null;
    notifyListeners();
    try {
      final result = await _authService.verifyOtp(userId: pendingUserId!, code: code);
      await _tokenStorage.saveSession(
        token: result.token,
        userId: result.user.id,
        userName: result.user.name,
        userEmail: result.user.email,
      );
      user = result.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      fieldErrors = e.fieldErrors;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore ANY failure (network error, timeout, malformed response,
      // revoked token, etc.) — the local session must clear and the app
      // must return to the login screen regardless of whether the server
      // round-trip succeeded. Catching only ApiException left this call
      // able to silently strand the user on the current screen whenever
      // something other than a mapped API error was thrown.
    }
    await _clearLocalSession();
  }

  /// Called when the user backs out of the OTP screen. No token was ever
  /// issued at this point, so there's nothing to revoke or clear — just
  /// drop back to the login form.
  void cancelOtp() {
    status = AuthStatus.unauthenticated;
    pendingUserId = null;
    errorMessage = null;
    fieldErrors = null;
    notifyListeners();
  }

  /// Called by the ApiClient interceptor when any request returns 401.
  Future<void> forceLogout() async {
    if (status == AuthStatus.unauthenticated) return;
    await _clearLocalSession();
  }

  Future<void> _clearLocalSession() async {
    try {
      await _tokenStorage.clear();
    } catch (_) {
      // Even if the secure-storage platform channel fails, the in-memory
      // status flip below must still happen — otherwise a storage hiccup
      // would leave the user stranded on the current screen exactly like
      // an uncaught logout-API error would.
    }
    user = null;
    pendingUserId = null;
    isLoading = false;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    fieldErrors = null;
    notifyListeners();
  }

  /// Changes the signed-in user's password via the same `/auth/profile`
  /// endpoint the web Profile page uses. Left out of the shared
  /// isLoading/errorMessage pair (those drive the login/OTP screens) so the
  /// Change Password screen manages its own submit state and can surface
  /// per-field errors without disturbing the rest of the app.
  Future<AppUser> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final currentUser = user;
    if (currentUser == null) {
      throw ApiException(message: 'You are not logged in.');
    }
    final updated = await _authService.changePassword(
      currentUser: currentUser,
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
    user = updated;
    notifyListeners();
    return updated;
  }
}
