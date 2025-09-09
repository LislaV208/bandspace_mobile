import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/reset_password_state.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';

/// Cubit zarządzający stanem resetowania hasła
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository authRepository;

  ResetPasswordCubit({required this.authRepository}) : super(const ResetPasswordInitial());

  /// Waliduje email
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      return false;
    }

    // Podstawowa walidacja formatu email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Wysyła żądanie resetowania hasła
  Future<void> requestPasswordReset(String email) async {
    // Walidacja email
    if (!_validateEmail(email)) {
      emit(const ResetPasswordFailure(message: "Wprowadź prawidłowy adres email."));
      return;
    }

    // Ustaw stan ładowania
    emit(const ResetPasswordLoading());

    try {
      // Wywołanie metody żądania resetowania hasła z repozytorium
      final response = await authRepository.forgotPassword(email: email.trim());

      // Sukces - pokaż komunikat
      emit(ResetPasswordSuccess(
        message: response.message.isNotEmpty 
          ? response.message 
          : "Link do resetowania hasła został wysłany na podany adres email. Sprawdź skrzynkę odbiorczą i kliknij w link, aby dokończyć proces resetowania hasła.",
      ));
    } catch (e) {
      emit(ResetPasswordFailure(message: e.toString()));
    }
  }

  /// Resetuje stan do początku procesu
  void resetState() {
    emit(const ResetPasswordInitial());
  }
}
