import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/authentication_state.dart';
import 'package:bandspace_mobile/features/auth/repository/authentication_repository.dart';
import 'package:bandspace_mobile/features/auth/services/authentication_storage.dart';
import 'package:bandspace_mobile/shared/utils/error_logger.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AuthenticationRepository repository;
  final AuthenticationStorage storage;

  AuthenticationCubit({
    required this.repository,
    required this.storage,
  }) : super(AuthenticationInitial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final tokens = await storage.getTokens();
      if (tokens != null) {
        emit(Authenticated(tokens: tokens));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      log(getErrorMessage(e));
      emit(Unauthenticated());
    }
  }

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
      await storage.saveTokens(tokens);
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
      final tokens = await repository.registerWithEmail(
        email: email,
        password: password,
      );
      await storage.saveTokens(tokens);
      emit(Authenticated(tokens: tokens));
    } catch (e) {
      emit(AuthenticationError(e));
    }
  }

  // Future<void> authenticateWithGoogle() async {}

  Future<void> onSignedOut() async {
    await storage.clearTokens();
    emit(Unauthenticated());
  }
}
