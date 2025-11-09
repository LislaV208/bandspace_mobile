import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/authentication/authentication_tokens.dart';

sealed class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Aplikacja dopiero startuje i jeszcze nie wiemy
/// czy uzytkownik jest zalogowany czy nie
class AuthenticationInitial extends AuthenticationState {}

/// Uzytkownik nie jest zalogowany
class Unauthenticated extends AuthenticationState {}

/// Niezalogowany uzytkownik jest w trakcie logowania
class Authenticating extends Unauthenticated {}

/// Niezalogowany uzytkownik z nieokreślonym błędem
class UnauthenticatedFailed extends Unauthenticated {
  final Object error;

  UnauthenticatedFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Niezalogowany uzytkownik ktoremu wygasla sesja
class UnauthenticatedExpired extends Unauthenticated {}

/// Niezalogowany uzytkownik ktory się wylogował
class UnauthenticatedSignedOut extends Unauthenticated {}

/// Uzytkownik jest zalogowany
class Authenticated extends AuthenticationState {
  final AuthenticationTokens tokens;

  Authenticated({required this.tokens});

  @override
  List<Object?> get props => [tokens];
}
