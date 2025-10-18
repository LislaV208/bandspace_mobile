import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/core/di/app_providers.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/features/splash/screens/splash_screen.dart';

/// Główna funkcja uruchamiająca aplikację.
///
/// Parametr [envFileName] określa nazwę pliku konfiguracyjnego, który ma zostać załadowany.
/// Domyślnie używany jest plik '.env'.
Future<void> main({String envFileName = '.env'}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Załadowanie odpowiedniego pliku .env
  await EnvConfig().init(fileName: envFileName);

  // Ustawienie przezroczystego statusbara
  AppTheme.setStatusBarColor();

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig().sentryDsn;
      options.attachScreenshot = true;
    },
    // Init your App.
    appRunner: () => runApp(
      SentryWidget(
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appProviders,
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Synchronizuj kontekst użytkownika z Sentry przy każdej zmianie stanu auth
          final user = state.user;
          if (user != null) {
            // Użytkownik zalogowany - ustaw kontekst w Sentry
            setSentryUser(
              userId: user.id.toString(),
              email: user.email,
              username: user.name,
            );
          } else {
            // Użytkownik wylogowany - wyczyść kontekst w Sentry
            setSentryUser();
          }
        },
        child: MaterialApp(
          title: 'BandSpace',
          theme: AppTheme.darkTheme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
