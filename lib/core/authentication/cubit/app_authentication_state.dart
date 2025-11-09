import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/authentication/authentication_tokens.dart';

sealed class AppAuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Aplikacja dopiero startuje i jeszcze nie wiemy
/// czy uzytkownik jest zalogowany czy nie
class AppAuthenticationInitial extends AppAuthenticationState {}

/// Uzytkownik nie jest zalogowany
class AppUnauthenticated extends AppAuthenticationState {}

/// Niezalogowany uzytkownik jest w trakcie logowania
class AppAuthenticating extends AppUnauthenticated {}

/// Niezalogowany uzytkownik z nieokreślonym błędem
class AppUnauthenticatedFailed extends AppUnauthenticated {
  final Object error;

  AppUnauthenticatedFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Niezalogowany uzytkownik ktoremu wygasla sesja
class AppUnauthenticatedExpired extends AppUnauthenticated {}

/// Niezalogowany uzytkownik ktory się wylogował
class AppUnauthenticatedSignedOut extends AppUnauthenticated {}

/// Uzytkownik jest zalogowany
class AppAuthenticated extends AppAuthenticationState {
  final AuthenticationTokens tokens;

  AppAuthenticated({required this.tokens});

  @override
  List<Object?> get props => [tokens];
}
