import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_state.dart';
import 'package:bandspace_mobile/features/auth/repository/authentication_repository.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository repository;

  AuthenticationCubit({
    required this.repository,
  }) : super(AuthenticationInitial());

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthenticationInProgress());

    try {
      final tokens = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(Authenticated(tokens: tokens));
    } catch (e) {
      emit(AuthenticationError(e));
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthenticationInProgress());

    try {
      final tokens = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(Authenticated(tokens: tokens));
    } catch (e) {
      emit(AuthenticationError(e));
    }
  }

  // Future<void> authenticateWithGoogle() async {}
}
