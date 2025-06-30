import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubit/reset_password_state.dart';
import 'package:bandspace_mobile/core/repositories/auth_repository.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Cubit zarządzający stanem resetowania hasła
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository authRepository;

  ResetPasswordCubit({required this.authRepository}) : super(const ResetPasswordState());

  // Kontrolery tekstowe
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Węzły fokusa
  final FocusNode emailFocus = FocusNode();
  final FocusNode tokenFocus = FocusNode();
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  Future<void> close() {
    // Zwolnienie zasobów
    emailController.dispose();
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    emailFocus.dispose();
    tokenFocus.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    return super.close();
  }

  /// Przełącza widoczność nowego hasła
  void toggleNewPasswordVisibility() {
    emit(state.copyWith(showNewPassword: !state.showNewPassword));
  }

  /// Przełącza widoczność potwierdzenia hasła
  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  /// Resetuje stan do początku procesu
  void resetState() {
    emit(const ResetPasswordState());
    _clearAllFields();
  }

  /// Waliduje email
  bool _validateEmail() {
    if (emailController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź adres email.")));
      return false;
    }

    // Podstawowa walidacja formatu email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(emailController.text)) {
      emit(state.copyWith(errorMessage: Value("Wprowadź prawidłowy adres email.")));
      return false;
    }

    return true;
  }

  /// Waliduje formularz resetowania hasła
  bool _validateResetForm() {
    if (tokenController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź token resetowania.")));
      return false;
    }

    if (newPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź nowe hasło.")));
      return false;
    }

    if (newPasswordController.text.length < 6) {
      emit(state.copyWith(errorMessage: Value("Nowe hasło musi mieć co najmniej 6 znaków.")));
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Potwierdź nowe hasło.")));
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      emit(state.copyWith(errorMessage: Value("Hasła nie są zgodne.")));
      return false;
    }

    return true;
  }

  /// Wysyła żądanie resetowania hasła
  Future<void> requestPasswordReset() async {
    // Wyczyść poprzednie komunikaty
    emit(state.copyWith(
      errorMessage: Value(null),
      successMessage: Value(null),
    ));

    // Walidacja email
    if (!_validateEmail()) {
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody żądania resetowania hasła z repozytorium
      final response = await authRepository.forgotPassword(
        email: emailController.text.trim(),
      );

      // Wyczyść stan ładowania i przejdź do następnego kroku
      emit(state.copyWith(
        isLoading: false,
        step: ResetPasswordStep.enterToken,
        successMessage: Value(response.message),
        resetToken: Value(response.resetToken), // Tylko w środowisku testowym
      ));

      // Automatycznie wypełnij token w środowisku testowym
      if (response.resetToken != null) {
        tokenController.text = response.resetToken!;
      }
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd wysyłania żądania: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(
        isLoading: false,
        errorMessage: Value(errorMessage),
      ));
    }
  }

  /// Resetuje hasło używając tokenu
  Future<void> resetPassword() async {
    // Wyczyść poprzednie komunikaty
    emit(state.copyWith(
      errorMessage: Value(null),
      successMessage: Value(null),
    ));

    // Walidacja formularza
    if (!_validateResetForm()) {
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody resetowania hasła z repozytorium
      final response = await authRepository.resetPassword(
        token: tokenController.text.trim(),
        newPassword: newPasswordController.text,
      );

      // Wyczyść stan ładowania i przejdź do kroku zakończenia
      emit(state.copyWith(
        isLoading: false,
        step: ResetPasswordStep.completed,
        successMessage: Value(response.message),
      ));

      // Wyczyść pola formularza
      _clearResetFields();
    } catch (e) {
      // Obsługa błędów
      String errorMessage = "Błąd resetowania hasła: ${e.toString()}";

      // Sprawdzamy typ wyjątku i dostosowujemy komunikat
      if (e.toString().contains("ApiException")) {
        errorMessage = e.toString().replaceAll("ApiException: ", "");
      } else if (e.toString().contains("NetworkException")) {
        errorMessage = "Problem z połączeniem internetowym. Sprawdź swoje połączenie i spróbuj ponownie.";
      } else if (e.toString().contains("TimeoutException")) {
        errorMessage = "Upłynął limit czasu połączenia. Spróbuj ponownie później.";
      }

      emit(state.copyWith(
        isLoading: false,
        errorMessage: Value(errorMessage),
      ));
    }
  }

  /// Powraca do poprzedniego kroku
  void goBack() {
    if (state.step == ResetPasswordStep.enterToken) {
      emit(state.copyWith(
        step: ResetPasswordStep.enterEmail,
        errorMessage: Value(null),
        successMessage: Value(null),
      ));
      tokenController.clear();
    }
  }

  /// Czyści pola resetowania hasła
  void _clearResetFields() {
    tokenController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Czyści wszystkie pola
  void _clearAllFields() {
    emailController.clear();
    tokenController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Czyści komunikaty błędów i sukcesu
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: Value(null),
      successMessage: Value(null),
    ));
  }
}