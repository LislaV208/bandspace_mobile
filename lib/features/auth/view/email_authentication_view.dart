import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_screen_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_screen_state.dart';
import 'package:bandspace_mobile/features/auth/screens/auth_screen.dart';
import 'package:bandspace_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:bandspace_mobile/shared/utils/validators.dart';

class EmailAuthenticationView extends StatefulWidget {
  const EmailAuthenticationView({
    super.key,
    required this.state,
  });

  final EmailAuthentication state;

  @override
  State<EmailAuthenticationView> createState() =>
      _EmailAuthenticationViewState();
}

class _EmailAuthenticationViewState extends State<EmailAuthenticationView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmPasswordController = TextEditingController();
  final _confirmPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isLoading = state is EmailAuthenticationLoading;
    final isLoginView = state.runtimeType == EmailAuthenticationLogin;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                context
                    .read<AuthenticationScreenCubit>()
                    .useGoogleAuthentication();
              },
              label: Text('Użyj konta Google'),
              icon: Icon(Icons.arrow_back),
            ),
          ),

          const SizedBox(height: 24),

          // Email field
          TextFormField(
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
            controller: _passwordController,
            focusNode: _passwordFocus,
            decoration: InputDecoration(
              hintText: "Hasło",
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => context
                    .read<AuthenticationScreenCubit>()
                    .togglePasswordVisibility(),
              ),
            ),
            obscureText: !state.showPassword,
            validator: (value) => validatePassword(value),
          ),

          // Confirm password (for register),
          AnimatedSwitcher(
            duration: AuthScreen.transitionDuration,
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
                          curve: AuthScreen.transitionCurve,
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
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    decoration: InputDecoration(
                      hintText: "Potwierdź hasło",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          state.showRepeatedPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => context
                            .read<AuthenticationScreenCubit>()
                            .toggleRepeatedPasswordVisibility(),
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
              EmailAuthenticationLogin() => Column(
                children: [
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen.create(),
                        ),
                      ),
                      child: Text(
                        "Zapomniałeś hasła?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _ => const SizedBox.shrink(),
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _formKey.currentState?.validate();
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
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
            duration: AuthScreen.transitionDuration,
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
                      : context
                            .read<AuthenticationScreenCubit>()
                            .toggleEmailAuthenticationView,
                  child: Text(
                    isLoginView ? "Zarejestruj się" : "Zaloguj się",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
