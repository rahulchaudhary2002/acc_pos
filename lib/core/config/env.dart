class Env {
  Env._();

  /// Base URL for the Laravel API. Override per-environment without touching
  /// code: `flutter run --dart-define=API_BASE_URL=http://<lan-ip>:8210/api`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8210/api',
  );
}
