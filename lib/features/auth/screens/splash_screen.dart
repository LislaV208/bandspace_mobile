import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/shared/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AuthenticationCubit>().initialize();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo aplikacji
            const Icon(
              LucideIcons.music,
              color: AppColors.primary,
              size: 64,
            ),
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
    );
  }
}
