import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/core/cubit/app_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/repositories/auth_repository.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/repositories/user_repository.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_cubit.dart';
import 'package:bandspace_mobile/splash/splash_screen.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => ProjectRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
      ],
      child: Builder(
        builder: (context) {
          final authCubit = AuthCubit(authRepository: context.read<AuthRepository>());
          final dashboardCubit = DashboardCubit(projectRepository: context.read<ProjectRepository>());
          final appCubit = AppCubit(authCubit: authCubit, dashboardCubit: dashboardCubit);
          
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: authCubit),
              BlocProvider<DashboardCubit>.value(value: dashboardCubit),
              BlocProvider<AppCubit>.value(value: appCubit),
            ],
            child: MaterialApp(
              title: 'BandSpace',
              theme: AppTheme.darkTheme,
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
