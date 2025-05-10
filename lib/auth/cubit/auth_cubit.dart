import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

/// Cubit zarządzający stanem ekranu autoryzacji
class AuthCubit extends Cubit<AuthState> {
  // Kontrolery tekstowe
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Węzły fokusa
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  AuthCubit() : super(const AuthState());

  @override
  Future<void> close() {
    // Zwolnienie zasobów
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    return super.close();
  }

  /// Przełącza widok między logowaniem a rejestracją
  void toggleView() {
    final newView = state.view == AuthView.login ? AuthView.register : AuthView.login;

    // Wyczyść pole potwierdzenia hasła przy przejściu do logowania
    if (newView == AuthView.login) {
      confirmPasswordController.clear();
    }

    emit(
      state.copyWith(
        view: newView,
        errorMessage: null, // Wyczyść błędy przy zmianie widoku
        showConfirmPassword: newView == AuthView.register ? false : state.showConfirmPassword,
      ),
    );
  }

  /// Przełącza widoczność hasła
  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  /// Przełącza widoczność potwierdzenia hasła
  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  /// Obsługuje proces logowania
  Future<void> login() async {
    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Symulacja opóźnienia sieciowego
      await Future.delayed(const Duration(seconds: 2));

      // Tutaj dodaj rzeczywistą logikę logowania
      // np. wywołanie API, Firebase Auth, itp.

      // Dla celów demonstracyjnych, zawsze sukces
      // W rzeczywistej implementacji, tutaj byłaby logika weryfikacji

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Tutaj można by wywołać nawigację do następnego ekranu
      // lub zaktualizować globalny stan aplikacji
    } catch (e) {
      // Obsługa błędów
      emit(state.copyWith(isLoading: false, errorMessage: "Błąd logowania: ${e.toString()}"));
    }
  }

  /// Obsługuje proces rejestracji
  Future<void> register() async {
    // Sprawdź, czy hasła są zgodne
    if (passwordController.text != confirmPasswordController.text) {
      emit(state.copyWith(errorMessage: "Hasła nie są zgodne."));
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Symulacja opóźnienia sieciowego
      await Future.delayed(const Duration(seconds: 2));

      // Tutaj dodaj rzeczywistą logikę rejestracji
      // np. wywołanie API, Firebase Auth, itp.

      // Dla celów demonstracyjnych, zawsze sukces
      // W rzeczywistej implementacji, tutaj byłaby logika rejestracji

      // Wyczyść stan ładowania
      emit(state.copyWith(isLoading: false));

      // Tutaj można by wywołać nawigację do następnego ekranu
      // lub zaktualizować globalny stan aplikacji
    } catch (e) {
      // Obsługa błędów
      emit(state.copyWith(isLoading: false, errorMessage: "Błąd rejestracji: ${e.toString()}"));
    }
  }

  /// Obsługuje logowanie przez Google
  Future<void> loginWithGoogle() async {
    // Tutaj dodaj rzeczywistą logikę logowania przez Google
    // np. Firebase Auth, Google Sign-In, itp.
    debugPrint("Próba logowania przez Google");

    // W rzeczywistej implementacji, tutaj byłaby logika logowania przez Google
  }

  /// Otwiera modal resetowania hasła
  void openResetPasswordModal(BuildContext context) {
    // Implementacja pozostaje w widoku, ponieważ wymaga kontekstu
    // i jest ściśle związana z UI
  }
}
