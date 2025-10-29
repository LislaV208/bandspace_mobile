import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/features/auth/models/authentication_tokens.dart';

sealed class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class Unauthenticated extends AuthenticationState {}

class AuthenticationInProgress extends Unauthenticated {}

class AuthenticationError extends Unauthenticated {
  final Object error;

  AuthenticationError(this.error);

  @override
  List<Object?> get props => [error];
}

class Authenticated extends AuthenticationState {
  final AuthenticationTokens tokens;

  Authenticated({required this.tokens});

  @override
  List<Object?> get props => [tokens];
}
