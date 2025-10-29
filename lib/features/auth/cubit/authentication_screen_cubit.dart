import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_screen_state.dart';

class AuthenticationScreenCubit extends Cubit<AuthenticationScreenState> {
  AuthenticationScreenCubit() : super(GoogleAuthentication());

  void useGoogleAuthentication() => emit(GoogleAuthentication());

  void useEmailAuthentication() => emit(
    EmailAuthenticationLogin(
      showPassword: false,
    ),
  );

  void toggleEmailAuthenticationView() {
    var currentState = state;
    if (currentState.runtimeType == EmailAuthenticationLogin) {
      currentState = currentState as EmailAuthenticationLogin;
      emit(
        EmailAuthenticationRegister(
          showPassword: currentState.showPassword,
          showRepeatedPassword: false,
        ),
      );
    } else if (currentState.runtimeType == EmailAuthenticationRegister) {
      currentState = currentState as EmailAuthenticationRegister;
      emit(
        EmailAuthenticationLogin(
          showPassword: currentState.showPassword,
        ),
      );
    }
  }

  void togglePasswordVisibility() {
    final currentState = state;
    if (currentState is EmailAuthenticationLogin) {
      emit(
        EmailAuthenticationLogin.togglePasswordVisibility(currentState),
      );
    }
  }

  void toggleRepeatedPasswordVisibility() {
    final currentState = state;
    if (currentState is EmailAuthenticationRegister) {
      emit(
        EmailAuthenticationRegister.toggleRepeatedPasswordVisibility(
          currentState,
        ),
      );
    }
  }
}
