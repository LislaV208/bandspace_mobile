import 'package:equatable/equatable.dart';

/// Abstrakcyjna klasa bazowa dla stanów resetowania hasła
abstract class ResetPasswordState extends Equatable {
  const ResetPasswordState();
}

/// Stan inicjalny resetowania hasła
class ResetPasswordInitial extends ResetPasswordState {
  const ResetPasswordInitial();

  @override
  List<Object?> get props => [];
}

/// Stan ładowania podczas wysyłania emaila
class ResetPasswordLoading extends ResetPasswordState {
  const ResetPasswordLoading();

  @override
  List<Object?> get props => [];
}

/// Stan sukcesu - email został wysłany
class ResetPasswordSuccess extends ResetPasswordState {
  final String message;

  const ResetPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Stan błędu resetowania hasła
class ResetPasswordFailure extends ResetPasswordState {
  final Object error;

  const ResetPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
