import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/theme/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLoginView = true;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage; // To display errors

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  // Animation configuration (approximating Svelte's quintOut)
  static const Duration _elementTransitionDuration = Duration(milliseconds: 300);
  static const Curve _elementTransitionCurve =
      Curves.easeOutQuart; // Svelte's quintOut is close to Quartic or Quintic easeOut

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
      _errorMessage = null; // Clear error on view switch
      // Clear confirm password field if switching from register to login
      if (_isLoginView) {
        _confirmPasswordController.clear();
        _showConfirmPassword = false; // Reset confirm password visibility
      }
    });
  }

  void _handleLogin() async {
    // UI only: simulate loading
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    // Simulate an error for demonstration
    // setState(() => _errorMessage = "Invalid credentials. Please try again.");
    setState(() => _isLoading = false);
    // On success, navigate or update app state
  }

  void _handleRegister() async {
    // UI only: simulate loading
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match.");
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    // Simulate an error for demonstration
    // setState(() => _errorMessage = "This email is already registered.");
    setState(() => _isLoading = false);
    // On success, navigate or update app state
  }

  void _handleGoogleLogin() async {
    // UI only: simulate loading
    // No loading state needed for a redirect, but for an API call it would be
    // print jest używany tylko do celów demonstracyjnych - w produkcji należy użyć frameworka do logowania
    debugPrint("Attempting Google Login");
  }

  void _openResetPasswordModal() {
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
                  decoration: const InputDecoration(labelText: "Enter your email"),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  // Add reset password logic
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Password reset link sent (simulated).")));
                },
                child: const Text("Send Link"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        key: ValueKey<bool>(_isLoginView), // Important for AnimatedSwitcher
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoginView ? "Witaj z powrotem!" : "Dołącz do BandSpace",
                            style: AppTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoginView
                                ? "Zaloguj się, aby kontynuować pracę nad swoimi projektami."
                                : "Utwórz konto, aby rozpocząć współpracę muzyczną.",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.errorBackground,
                          border: Border.all(color: AppColors.errorBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_errorMessage!, style: AppTextStyles.error, textAlign: TextAlign.center),
                      ),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: "Wprowadź swój email",
                      prefixIcon: const Icon(Icons.mail_outline, color: AppColors.iconSecondary),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hintText: "Wprowadź swoje hasło",
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
                      obscureText: !_showPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.iconSecondary,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password (Only for Login)
                    if (_isLoginView)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openResetPasswordModal,
                          child: Text("Zapomniałeś hasła?", style: AppTextStyles.link),
                        ),
                      ),
                    if (_isLoginView) const SizedBox(height: 8),

                    // Confirm Password (Animated for Register View)
                    AnimatedContainer(
                      duration: _elementTransitionDuration,
                      curve: _elementTransitionCurve,
                      height: _isLoginView ? 0 : 80, // Approximate height of field + padding
                      child: OverflowBox(
                        // To allow content to be drawn even if height is 0 during animation
                        minHeight: 0,
                        maxHeight: 80, // Ensure it doesn't take too much space when visible
                        child: AnimatedOpacity(
                          duration: _elementTransitionDuration,
                          curve: _elementTransitionCurve,
                          opacity: _isLoginView ? 0.0 : 1.0,
                          child: Transform.translate(
                            offset: Offset(0, _isLoginView ? -10 : 0),
                            child: _buildTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              hintText: "Potwierdź hasło",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
                              obscureText: !_showConfirmPassword,
                              enabled: !_isLoginView,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.iconSecondary,
                                ),
                                onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Adjust spacing based on whether confirm password is shown
                    SizedBox(height: _isLoginView ? 16 : 24),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // bg-blue-600
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        disabledBackgroundColor: const Color(0xFF2563EB).withAlpha(128), // 0.5 * 255 = 127.5 ≈ 128
                      ),
                      onPressed: _isLoading ? null : (_isLoginView ? _handleLogin : _handleRegister),
                      child:
                          _isLoading
                              ? SizedBox(
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
                                  key: ValueKey<bool>(_isLoginView),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isLoginView ? Icons.login : Icons.person_add_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isLoginView ? "Zaloguj się" : "Utwórz konto",
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
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                    ),
                    const SizedBox(height: 24),

                    // Toggle Login/Register
                    AnimatedSwitcher(
                      duration: _elementTransitionDuration,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Row(
                        key: ValueKey<bool>(_isLoginView),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLoginView ? "Nie masz konta?" : "Masz już konto?", style: AppTextStyles.caption),
                          TextButton(
                            onPressed: _isLoading ? null : _toggleView,
                            child: Text(_isLoginView ? "Zarejestruj się" : "Zaloguj się", style: AppTextStyles.link),
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
