import 'package:equatable/equatable.dart';

abstract class AuthenticationScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Google Authentication
class GoogleAuthentication extends AuthenticationScreenState {}

class GoogleAuthenticationLoading extends GoogleAuthentication {}

class GoogleAuthenticationSuccess extends GoogleAuthentication {}

class GoogleAuthenticationError extends GoogleAuthentication {
  final Object error;

  GoogleAuthenticationError(this.error);

  @override
  List<Object?> get props => [...super.props, error];
}

// Email Authentication
class EmailAuthentication extends AuthenticationScreenState {
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
