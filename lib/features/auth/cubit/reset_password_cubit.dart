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

      emit(ResetPasswordFailure(message: errorMessage));
    }
  }

  /// Resetuje stan do początku procesu
  void resetState() {
    emit(const ResetPasswordInitial());
  }
}
