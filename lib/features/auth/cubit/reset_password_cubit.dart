import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/reset_password_state.dart';
import 'package:bandspace_mobile/features/auth/repository/authentication_repository.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthenticationRepository repository;

  ResetPasswordCubit({required this.repository}) : super(const ResetPasswordInitial());

  Future<void> requestPasswordReset(String email) async {
    emit(const ResetPasswordLoading());

    try {
      final response = await repository.requestPasswordReset(
        email: email.trim(),
      );

      emit(
        ResetPasswordSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : "Link do resetowania hasła został wysłany na podany adres email. Sprawdź skrzynkę odbiorczą i kliknij w link, aby dokończyć proces resetowania hasła.",
        ),
      );
    } catch (e) {
      emit(ResetPasswordFailure(e));
    }
  }
}
