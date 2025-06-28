import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/dashboard/dashboard_screen.dart';

/// Ekran ładowania wyświetlany podczas sprawdzania stanu logowania użytkownika.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('SplashScreen build');
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Gdy stan autentykacji zostanie ustalony, przekieruj do odpowiedniego ekranu
        if (state.isAuthStateInitialized) {
          if (state.user != null) {
            // Użytkownik jest zalogowany, przekieruj do DashboardScreen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
          } else {
            // Użytkownik nie jest zalogowany, przekieruj do AuthScreen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthScreen()));
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo aplikacji
              const Icon(LucideIcons.music, color: AppColors.primary, size: 64),
              const SizedBox(height: 16),
              Text('BandSpace', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary)),
              const SizedBox(height: 32),
              // Wskaźnik ładowania
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
