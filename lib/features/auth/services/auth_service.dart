import '../../../core/network/api_client.dart';
import '../models/user.dart';

/// Result of step 1 of the mobile POS login flow — always requires OTP verification.
class LoginResult {
  final int userId;
  final String message;

  LoginResult({required this.userId, required this.message});
}

class VerifyOtpResult {
  final String token;
  final AppUser user;

  VerifyOtpResult({required this.token, required this.user});
}

/// Talks to `/api/pos/auth/*` — the mobile POS auth flow (Sanctum bearer
/// tokens), distinct from the web session + email-2FA flow used by the admin UI.
class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<LoginResult> login({required String email, required String password}) async {
    final data = await _client.post('/pos/auth/login', data: {
      'email': email,
      'password': password,
    });
    return LoginResult(
      userId: data['user_id'] as int,
      message: data['message'] as String? ?? '',
    );
  }

  Future<VerifyOtpResult> verifyOtp({required int userId, required String code}) async {
    final data = await _client.post('/pos/auth/verify-otp', data: {
      'user_id': userId,
      'code': code,
    });
    return VerifyOtpResult(
      token: data['token'] as String,
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _client.post('/pos/auth/logout');
  }
}
