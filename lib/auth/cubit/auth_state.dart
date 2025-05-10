import 'package:equatable/equatable.dart';

/// Enum reprezentujący różne widoki ekranu autoryzacji
enum AuthView {
  login,
  register,
}

/// Klasa bazowa dla wszystkich stanów autoryzacji
class AuthState extends Equatable {
  final AuthView view;
  final bool isLoading;
  final String? errorMessage;
  final bool showPassword;
  final bool showConfirmPassword;

  const AuthState({
    this.view = AuthView.login,
    this.isLoading = false,
    this.errorMessage,
    this.showPassword = false,
    this.showConfirmPassword = false,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  AuthState copyWith({
    AuthView? view,
    bool? isLoading,
    String? errorMessage,
    bool? showPassword,
    bool? showConfirmPassword,
  }) {
    return AuthState(
      view: view ?? this.view,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
    );
  }

  @override
  List<Object?> get props => [
        view,
        isLoading,
        errorMessage,
        showPassword,
        showConfirmPassword,
      ];
}
