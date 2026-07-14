import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/providers/locale_provider.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/pos/providers/buy_cart_provider.dart';
import 'features/pos/providers/cart_provider.dart';
import 'features/pos/providers/date_locale_provider.dart';
import 'features/pos/providers/pos_config_provider.dart';
import 'features/pos/providers/pos_data_provider.dart';
import 'features/pos/providers/printer_provider.dart';
import 'features/pos/providers/voice_announcer.dart';
import 'features/pos/screens/pos_home_screen.dart';
import 'features/pos/services/pos_service.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage: tokenStorage);
    final authService = AuthService(apiClient);
    final posService = PosService(apiClient);

    return MultiProvider(
      providers: [
        Provider.value(value: tokenStorage),
        Provider.value(value: apiClient),
        Provider.value(value: posService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: authService, tokenStorage: tokenStorage)..bootstrap(),
        ),
        ChangeNotifierProvider(create: (_) => PosConfigProvider(posService: posService, tokenStorage: tokenStorage)),
        ChangeNotifierProvider(create: (_) => PosDataProvider(posService)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => BuyCartProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAnnouncer()..init()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()..init()),
        ChangeNotifierProvider(create: (_) => DateLocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
      ],
      child: _AppRoot(apiClient: apiClient),
    );
  }
}

class _AppRoot extends StatefulWidget {
  final ApiClient apiClient;

  const _AppRoot({required this.apiClient});

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    // Wire the ApiClient's 401 hook to AuthProvider once the provider tree exists.
    widget.apiClient.onUnauthorized = () {
      context.read<AuthProvider>().forceLogout();
    };
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: 'POS',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.checking:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const PosHomeScreen();
      case AuthStatus.otpRequired:
        return const OtpScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientMid, AppColors.gradientEnd],
          ),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
