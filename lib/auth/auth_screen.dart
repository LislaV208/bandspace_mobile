import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/dashboard/dashboard_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthScreenContent();
  }
}

class _AuthScreenContent extends StatelessWidget {
  // Animation configuration (approximating Svelte's quintOut)
  static const Duration _elementTransitionDuration = Duration(milliseconds: 300);
  static const Curve _elementTransitionCurve =
      Curves.easeOutQuart; // Svelte's quintOut is close to Quartic or Quintic easeOut

  const _AuthScreenContent();

  void _openResetPasswordModal(BuildContext context) {
    // In Flutter, you'd typically use showDialog or showModalBottomSheet
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reset Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Wprowadź swój email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Anuluj")),
              ElevatedButton(
                onPressed: () {
                  // Add reset password logic
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Link do resetowania hasła wysłany (symulacja).")));
                },
                child: const Text("Wyślij link"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pobieramy referencję do Cubita
    final authCubit = context.read<AuthCubit>();

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Obsługa nawigacji po udanym logowaniu/rejestracji
        if (state.user != null) {
          print(state);
          // Nawigacja do DashboardScreen
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
        }
      },
      builder: (context, state) {
        final isLoginView = state.view == AuthView.login;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Mobile Header (equivalent to Svelte's md:hidden block)
              Container(
                color: AppColors.primary,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16.0, // Status bar
                  bottom: 16.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.music, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text("BandSpace", style: AppTextStyles.headlineSmall),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // minHeight to push content down if screen is tall
                      minHeight:
                          MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).padding.top + 16.0 + 16.0 + 56) -
                          48, //Approx header and padding
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Animated Header Text
                        AnimatedSwitcher(
                          duration: _elementTransitionDuration,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.1, 0.0), // Fly in from right
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: _elementTransitionCurve));
                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: Column(
                            key: ValueKey<bool>(isLoginView), // Important for AnimatedSwitcher
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoginView ? "Witaj z powrotem!" : "Dołącz do BandSpace",
                                style: AppTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLoginView
                                    ? "Zaloguj się, aby kontynuować pracę nad swoimi projektami."
                                    : "Utwórz konto, aby rozpocząć współpracę muzyczną.",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        if (state.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.errorBackground,
                              border: Border.all(color: AppColors.errorBorder),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(state.errorMessage!, style: AppTextStyles.error, textAlign: TextAlign.center),
                          ),

                        // Email Field
                        _buildTextField(
                          controller: authCubit.emailController,
                          focusNode: authCubit.emailFocus,
                          hintText: "Wprowadź swój email",
                          prefixIcon: const Icon(Icons.mail_outline, color: AppColors.iconSecondary),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        _buildTextField(
                          controller: authCubit.passwordController,
                          focusNode: authCubit.passwordFocus,
                          hintText: "Wprowadź swoje hasło",
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
                          obscureText: !state.showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.iconSecondary,
                            ),
                            onPressed: () => authCubit.togglePasswordVisibility(),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Forgot Password (Only for Login)
                        if (isLoginView)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _openResetPasswordModal(context),
                              child: Text("Zapomniałeś hasła?", style: AppTextStyles.link),
                            ),
                          ),
                        if (isLoginView) const SizedBox(height: 8),

                        // Confirm Password (Animated for Register View)
                        AnimatedContainer(
                          duration: _elementTransitionDuration,
                          curve: _elementTransitionCurve,
                          height: isLoginView ? 0 : 80, // Approximate height of field + padding
                          child: OverflowBox(
                            // To allow content to be drawn even if height is 0 during animation
                            minHeight: 0,
                            maxHeight: 80, // Ensure it doesn't take too much space when visible
                            child: AnimatedOpacity(
                              duration: _elementTransitionDuration,
                              curve: _elementTransitionCurve,
                              opacity: isLoginView ? 0.0 : 1.0,
                              child: Transform.translate(
                                offset: Offset(0, isLoginView ? -10 : 0),
                                child: _buildTextField(
                                  controller: authCubit.confirmPasswordController,
                                  focusNode: authCubit.confirmPasswordFocus,
                                  hintText: "Potwierdź hasło",
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
                                  obscureText: !state.showConfirmPassword,
                                  enabled: !isLoginView,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.showConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.iconSecondary,
                                    ),
                                    onPressed: () => authCubit.toggleConfirmPasswordVisibility(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Adjust spacing based on whether confirm password is shown
                        SizedBox(height: isLoginView ? 16 : 24),

                        // Submit Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB), // bg-blue-600
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            disabledBackgroundColor: const Color(0xFF2563EB).withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
                          ),
                          onPressed: state.isLoading ? null : (isLoginView ? authCubit.login : authCubit.register),
                          child:
                              state.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                  : AnimatedSwitcher(
                                    duration: _elementTransitionDuration,
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.2, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      key: ValueKey<bool>(isLoginView),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isLoginView ? Icons.login : Icons.person_add_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isLoginView ? "Zaloguj się" : "Utwórz konto",
                                          style: const TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text("Lub kontynuuj z", style: AppTextStyles.caption),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        OutlinedButton.icon(
                          icon: Brand(Brands.google, size: 20), // From icons_plus
                          label: Text("Kontynuuj z Google", style: TextStyle(color: AppColors.textSecondary)),
                          onPressed: state.isLoading ? null : authCubit.loginWithGoogle,
                        ),
                        const SizedBox(height: 24),

                        // Toggle Login/Register
                        AnimatedSwitcher(
                          duration: _elementTransitionDuration,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Row(
                            key: ValueKey<bool>(isLoginView),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLoginView ? "Nie masz konta?" : "Masz już konto?", style: AppTextStyles.caption),
                              TextButton(
                                onPressed: state.isLoading ? null : authCubit.toggleView,
                                child: Text(isLoginView ? "Zarejestruj się" : "Zaloguj się", style: AppTextStyles.link),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Metoda pomocnicza do budowania pól formularza
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required Icon prefixIcon,
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(color: AppColors.textSecondary),
      decoration: AppInputDecorations.textField(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabled: enabled,
      ),
    );
  }
}
