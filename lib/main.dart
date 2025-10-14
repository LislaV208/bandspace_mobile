import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/core/di/app_providers.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
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

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appProviders,
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
    );
  }
}
