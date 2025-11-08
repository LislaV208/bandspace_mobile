import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_screen_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_screen_state.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_state.dart';
import 'package:bandspace_mobile/features/auth/view/email_authentication_view.dart';
import 'package:bandspace_mobile/features/auth/view/google_authentication_view.dart';
import 'package:bandspace_mobile/shared/theme/app_colors.dart';
import 'package:bandspace_mobile/shared/theme/text_styles.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const transitionDuration = Duration(milliseconds: 300);
  static const transitionCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: BlocSelector<AuthenticationCubit, AuthenticationState, bool>(
        selector: (state) => state is AuthenticationInitial,
        builder: (context, showLoading) {
          if (showLoading) {
            return Center(
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
            );
          }
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.music),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "BandSpace",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            120, // Header height approximation
                      ),
                      child: BlocBuilder<AuthenticationScreenCubit, AuthenticationScreenState>(
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 80),

                              // Animated switch between Google and Email auth
                              AnimatedSwitcher(
                                duration: transitionDuration,
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      final offsetAnimation =
                                          Tween<Offset>(
                                            begin: const Offset(0.0, 0.1),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: transitionCurve,
                                            ),
                                          );
                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                child: switch (state) {
                                  EmailAuthentication() => EmailAuthenticationView(state: state),
                                  GoogleAuthentication() => const GoogleAuthenticationView(),
                                  _ => const SizedBox.shrink(),
                                },
                              ),

                              const SizedBox(height: 48),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
