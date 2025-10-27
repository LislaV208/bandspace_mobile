import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/account/cubit/change_password_state.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';

/// Cubit zarządzający stanem zmiany hasła
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository authRepository;

  ChangePasswordCubit({required this.authRepository})
    : super(const ChangePasswordState());

  // Kontrolery tekstowe
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Węzły fokusa
  final FocusNode currentPasswordFocus = FocusNode();
  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  @override
  Future<void> close() {
    // Zwolnienie zasobów
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordFocus.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    return super.close();
  }

  /// Przełącza widoczność aktualnego hasła
  void toggleCurrentPasswordVisibility() {
    emit(state.copyWith(showCurrentPassword: !state.showCurrentPassword));
  }

  /// Przełącza widoczność nowego hasła
  void toggleNewPasswordVisibility() {
    emit(state.copyWith(showNewPassword: !state.showNewPassword));
  }

  /// Przełącza widoczność potwierdzenia hasła
  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  /// Waliduje formularz zmiany hasła
  bool _validateForm() {
    if (currentPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź aktualne hasło.")));
      return false;
    }

    if (newPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Wprowadź nowe hasło.")));
      return false;
    }

    if (newPasswordController.text.length < 6) {
      emit(
        state.copyWith(
          errorMessage: Value("Nowe hasło musi mieć co najmniej 6 znaków."),
        ),
      );
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      emit(state.copyWith(errorMessage: Value("Potwierdź nowe hasło.")));
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      emit(state.copyWith(errorMessage: Value("Nowe hasła nie są zgodne.")));
      return false;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      emit(
        state.copyWith(
          errorMessage: Value("Nowe hasło musi być różne od aktualnego."),
        ),
      );
      return false;
    }

    return true;
  }

  /// Obsługuje proces zmiany hasła
  Future<void> changePassword() async {
    // Wyczyść poprzednie komunikaty
    emit(
      state.copyWith(errorMessage: Value(null), successMessage: Value(null)),
    );

    // Walidacja formularza
    if (!_validateForm()) {
      return;
    }

    // Ustaw stan ładowania
    emit(state.copyWith(isLoading: true));

    try {
      // Wywołanie metody zmiany hasła z repozytorium
      final response = await authRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      // Wyczyść stan ładowania i wyświetl komunikat sukcesu
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: Value(response.message),
        ),
      );

      // Wyczyść pola formularza po udanej zmianie hasła
      _clearForm();
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Change password failed',
      );
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: Value(getErrorMessage(e)),
        ),
      );
    }
  }

  /// Czyści formularz zmiany hasła
  void _clearForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Czyści komunikaty błędów i sukcesu
  void clearMessages() {
    emit(
      state.copyWith(errorMessage: Value(null), successMessage: Value(null)),
    );
  }
}
