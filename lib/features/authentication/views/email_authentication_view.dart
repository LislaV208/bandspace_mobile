import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_cubit.dart';
import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_state.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication_screen/authentication_screen_cubit.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication_screen/authentication_screen_state.dart';
import 'package:bandspace_mobile/features/authentication/reset_password/cubit/reset_password_cubit.dart';
import 'package:bandspace_mobile/features/authentication/reset_password/reset_password_screen.dart';
import 'package:bandspace_mobile/features/authentication/views/authentication_view.dart';
import 'package:bandspace_mobile/shared/utils/validators.dart';

class EmailAuthenticationView extends StatefulWidget {
  const EmailAuthenticationView({
    super.key,
    required this.state,
  });

  final EmailAuthentication state;

  @override
  State<EmailAuthenticationView> createState() => _EmailAuthenticationViewState();
}

class _EmailAuthenticationViewState extends State<EmailAuthenticationView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    // text: kDebugMode ? 'lislav.hms@gmail.com' : null,
    text: kDebugMode ? 'app.bandspace@gmail.com' : null,
  );
  final _emailFocus = FocusNode();
  final _passwordController = TextEditingController(
    text: kDebugMode ? '@rbuz0Hol' : null,
  );
  final _passwordFocus = FocusNode();
  final _confirmPasswordController = TextEditingController();
  final _confirmPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppAuthenticationCubit, AppAuthenticationState>(
      builder: (context, authenticationState) {
        final state = widget.state;
        final isLoading = authenticationState is AppAuthenticating;
        final isLoginView = state.runtimeType == EmailAuthenticationLogin;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthenticationScreenCubit>().useGoogleAuthentication();
                        },
                  label: Text('Użyj konta Google'),
                  icon: Icon(Icons.arrow_back),
                ),
              ),

              const SizedBox(height: 24),

              // Email field
              TextFormField(
                enabled: !isLoading,
                controller: _emailController,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),

              const SizedBox(height: 16),

              // Password field
              TextFormField(
                enabled: !isLoading,
                controller: _passwordController,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                  hintText: "Hasło",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      state.showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      context.read<AuthenticationScreenCubit>().togglePasswordVisibility();
                    },
                  ),
                ),
                obscureText: !state.showPassword,
                validator: (value) => validatePassword(value),
              ),

              // Confirm password (for register),
              AnimatedSwitcher(
                duration: AuthenticationView.transitionDuration,
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
                              curve: AuthenticationView.transitionCurve,
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
                  EmailAuthenticationRegister() => Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        enabled: !isLoading,
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        decoration: InputDecoration(
                          hintText: "Potwierdź hasło",
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.showRepeatedPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              context.read<AuthenticationScreenCubit>().toggleRepeatedPasswordVisibility();
                            },
                          ),
                        ),
                        obscureText: !state.showRepeatedPassword,
                        validator: (value) => validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                    ],
                  ),
                  EmailAuthentication() => Column(
                    children: [
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => ResetPasswordCubit(
                                        repository: context.read(),
                                      ),
                                      child: const ResetPasswordScreen(),
                                    ),
                                  ),
                                ),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Text(
                            "Zapomniałeś hasła?",
                          ),
                        ),
                      ),
                    ],
                  ),
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final isValid = _formKey.currentState?.validate() ?? false;
                          if (!isValid) return;

                          final email = _emailController.text;
                          final password = _passwordController.text;

                          final authenticationCubit = context.read<AppAuthenticationCubit>();

                          if (isLoginView) {
                            authenticationCubit.signInWithEmail(
                              email: email,
                              password: password,
                            );
                          } else {
                            authenticationCubit.registerWithEmail(
                              email: email,
                              password: password,
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isLoginView ? "Zaloguj się" : "Utwórz konto",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: AuthenticationView.transitionDuration,
                child: Row(
                  key: ValueKey<bool>(isLoginView),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoginView ? "Nie masz konta?" : "Masz już konto?",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthenticationScreenCubit>().toggleEmailAuthenticationView();
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        isLoginView ? "Zarejestruj się" : "Zaloguj się",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
