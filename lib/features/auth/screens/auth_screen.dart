import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/storage/shared_preferences_storage.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/features/auth/screens/reset_password_screen.dart';
import 'package:bandspace_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthScreenContent();
  }
}

class _AuthScreenContent extends StatefulWidget {
  static const Duration _elementTransitionDuration = Duration(
    milliseconds: 300,
  );
  static const Curve _elementTransitionCurve = Curves.easeOutQuart;

  const _AuthScreenContent();

  @override
  State<_AuthScreenContent> createState() => _AuthScreenContentState();
}

class _AuthScreenContentState extends State<_AuthScreenContent> {
  bool _showEmailForm = false;

  void _openResetPasswordModal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ResetPasswordScreen.create()),
    );
  }

  void _toggleEmailForm() {
    setState(() {
      _showEmailForm = !_showEmailForm;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<SharedPreferencesStorage>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.user != null) {
          context.read<UserProfileCubit>().loadProfile();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen.create()),
          );
        }
      },
      builder: (context, state) {
        final isLoginView = state.view == AuthView.login;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // #111827
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // Clean minimal header
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            120, // Header height approximation
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 32),

                          // Welcome section
                          AnimatedSwitcher(
                            duration:
                                _AuthScreenContent._elementTransitionDuration,
                            child: Column(
                              key: ValueKey<bool>(isLoginView),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoginView
                                      ? "Witaj z powrotem!"
                                      : "Dołącz do BandSpace",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isLoginView
                                      ? "Zaloguj się, aby kontynuować pracę nad swoimi projektami."
                                      : "Utwórz konto, aby rozpocząć współpracę muzyczną.",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Error message
                          if (state.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer
                                    .withValues(alpha: 0.1),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Animated switch between Google and Email auth
                          AnimatedSwitcher(
                            duration:
                                _AuthScreenContent._elementTransitionDuration,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  final offsetAnimation =
                                      Tween<Offset>(
                                        begin: const Offset(0.0, 0.1),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: _AuthScreenContent
                                              ._elementTransitionCurve,
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
                            child: _showEmailForm
                                ? Column(
                                    key: const ValueKey('email_mode'),
                                    children: [
                                      _buildCleanEmailForm(
                                        context,
                                        state,
                                        authCubit,
                                        isLoginView,
                                      ),
                                    ],
                                  )
                                : Column(
                                    key: const ValueKey('google_mode'),
                                    children: [
                                      // Hero Google button
                                      _buildHeroGoogleButton(
                                        onPressed: state.isLoading
                                            ? null
                                            : authCubit.loginWithGoogle,
                                        isLoading: state.isLoading,
                                      ),

                                      const SizedBox(height: 32),

                                      // Email option - subtle and secondary
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: _toggleEmailForm,
                                          label: const Text(
                                            "Użyj adresu email i hasła",
                                          ),
                                          icon: const Icon(
                                            Icons.alternate_email,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          // Login/Register toggle - only when email form is shown
                          if (_showEmailForm) ...[
                            const SizedBox(height: 32),
                            AnimatedSwitcher(
                              duration:
                                  _AuthScreenContent._elementTransitionDuration,
                              child: Row(
                                key: ValueKey<bool>(isLoginView),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLoginView
                                        ? "Nie masz konta?"
                                        : "Masz już konto?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant, // #D1D5DB
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : authCubit.toggleView,
                                    child: Text(
                                      isLoginView
                                          ? "Zarejestruj się"
                                          : "Zaloguj się",
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

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroGoogleButton({
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // #1F2937
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline, // #374151
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else ...[
                  Brand(Brands.google, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    "Kontynuuj z kontem Google",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Colors.white
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCleanEmailForm(
    BuildContext context,
    AuthState state,
    AuthCubit authCubit,
    bool isLoginView,
  ) {
    return Column(
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _toggleEmailForm,
            label: Text('Użyj konta Google'),
            icon: Icon(Icons.arrow_back),
          ),
        ),

        const SizedBox(height: 24),

        // Email field
        TextFormField(
          controller: authCubit.emailController,
          focusNode: authCubit.emailFocus,
          decoration: InputDecoration(
            hintText: "Email",
            prefixIcon: Icon(Icons.alternate_email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Password field
        TextFormField(
          controller: authCubit.passwordController,
          focusNode: authCubit.passwordFocus,
          decoration: InputDecoration(
            hintText: "Hasło",
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                state.showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () => authCubit.togglePasswordVisibility(),
            ),
          ),
          obscureText: !state.showPassword,
        ),

        // Forgot password
        if (isLoginView) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openResetPasswordModal(context),
              child: Text(
                "Zapomniałeś hasła?",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],

        // Confirm password (for register)
        AnimatedContainer(
          duration: _AuthScreenContent._elementTransitionDuration,
          height: isLoginView ? 0 : null,
          child: AnimatedOpacity(
            duration: _AuthScreenContent._elementTransitionDuration,
            opacity: isLoginView ? 0.0 : 1.0,
            child: isLoginView
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: authCubit.confirmPasswordController,
                        focusNode: authCubit.confirmPasswordFocus,
                        decoration: InputDecoration(
                          hintText: "Potwierdź hasło",
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.showConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                authCubit.toggleConfirmPasswordVisibility(),
                          ),
                        ),
                        obscureText: !state.showConfirmPassword,
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : isLoginView
                ? authCubit.login
                : authCubit.register,
            child: state.isLoading
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
      ],
    );
  }
}
