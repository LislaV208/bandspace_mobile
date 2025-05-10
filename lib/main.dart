import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/repositories/auth_repository.dart';
import 'package:bandspace_mobile/dashboard/dashboard_screen.dart';
import 'package:bandspace_mobile/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ustawienie przezroczystego statusbara
  AppTheme.setStatusBarColor();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
      ],
      child: MaterialApp(
        title: 'BandSpace',
        theme: AppTheme.darkTheme,
        // Używamy AuthScreen jako ekranu głównego do testowania
        // Możesz przełączyć na DashboardScreen, aby zobaczyć ekran główny
        home: const AuthScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
