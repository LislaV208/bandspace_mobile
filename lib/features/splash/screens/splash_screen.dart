import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// import 'package:bandspace_mobile/shared/providers/connectivity_cubit.dart';
// import 'package:bandspace_mobile/shared/services/sync_service.dart';
import 'package:bandspace_mobile/core/navigation/custom_page_routes.dart';
import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/features/auth/screens/auth_screen.dart';
import 'package:bandspace_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';

/// Ekran ładowania wyświetlany podczas sprawdzania stanu logowania użytkownika.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Gdy stan autentykacji zostanie ustalony, przekieruj do odpowiedniego ekranu
        if (state.isAuthStateInitialized) {
          if (state.user != null) {
            // Niestandardowa animacja dla przejścia splash->dashboard
            context.read<UserProfileCubit>().loadProfile();
            Navigator.of(context).pushReplacement(
              FadePageRoute(page: DashboardScreen.create()),
            );
          } else {
            // Użytkownik nie jest zalogowany, przekieruj do AuthScreen
            Navigator.of(context).pushReplacement(
              FadePageRoute(page: const AuthScreen()),
            );
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
              Text(
                'BandSpace',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Wskaźnik ładowania
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
