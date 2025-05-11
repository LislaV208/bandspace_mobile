import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Enum reprezentujący różne widoki ekranu autoryzacji
enum AuthView { login, register }

/// Klasa bazowa dla wszystkich stanów autoryzacji
class AuthState extends Equatable {
  final AuthView view;
  final bool isLoading;
  final String? errorMessage;
  final bool showPassword;
  final bool showConfirmPassword;
  final User? user;

  /// Flaga wskazująca, czy stan autentykacji został zainicjalizowany.
  /// Używana do określenia, czy aplikacja powinna pokazać ekran ładowania czy przejść do odpowiedniego ekranu.
  final bool isAuthStateInitialized;

  const AuthState({
    this.view = AuthView.login,
    this.isLoading = false,
    this.errorMessage,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.user,
    this.isAuthStateInitialized = false,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  AuthState copyWith({
    AuthView? view,
    bool? isLoading,
    Value<String?>? errorMessage,
    bool? showPassword,
    bool? showConfirmPassword,
    Value<User?>? user,
    bool? isAuthStateInitialized,
  }) {
    return AuthState(
      view: view ?? this.view,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      user: user != null ? user.value : this.user,
      isAuthStateInitialized: isAuthStateInitialized ?? this.isAuthStateInitialized,
    );
  }

  @override
  List<Object?> get props => [
    view,
    isLoading,
    errorMessage,
    showPassword,
    showConfirmPassword,
    user,
    isAuthStateInitialized,
  ];
}
