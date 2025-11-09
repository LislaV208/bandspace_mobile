import 'package:equatable/equatable.dart';

sealed class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Google Authentication
class GoogleAuthentication extends AuthenticationState {}

// Email Authentication
class EmailAuthentication extends AuthenticationState {
  final bool showPassword;

  EmailAuthentication({required this.showPassword});

  @override
  List<Object?> get props => [...super.props, showPassword];
}

class EmailAuthenticationLogin extends EmailAuthentication {
  EmailAuthenticationLogin({required super.showPassword});

  factory EmailAuthenticationLogin.togglePasswordVisibility(
    EmailAuthenticationLogin state,
  ) {
    return switch (state) {
      EmailAuthenticationRegister() => EmailAuthenticationRegister(
        showPassword: !state.showPassword,
        showRepeatedPassword: state.showRepeatedPassword,
      ),
      EmailAuthenticationLogin() => EmailAuthenticationLogin(
        showPassword: !state.showPassword,
      ),
    };
  }
}

class EmailAuthenticationRegister extends EmailAuthenticationLogin {
  final bool showRepeatedPassword;

  EmailAuthenticationRegister({
    required super.showPassword,
    required this.showRepeatedPassword,
  });

  factory EmailAuthenticationRegister.toggleRepeatedPasswordVisibility(
    EmailAuthenticationRegister state,
  ) {
    return EmailAuthenticationRegister(
      showPassword: state.showPassword,
      showRepeatedPassword: !state.showRepeatedPassword,
    );
  }

  @override
  List<Object?> get props => [...super.props, showRepeatedPassword];
}
