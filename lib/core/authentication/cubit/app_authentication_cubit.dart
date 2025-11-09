import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/authentication/authentication_storage.dart';
import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_state.dart';
import 'package:bandspace_mobile/features/authentication/repository/authentication_repository.dart';

class AppAuthenticationCubit extends Cubit<AppAuthenticationState> {
  final AuthenticationRepository repository;
  final AuthenticationStorage storage;

  AppAuthenticationCubit({
    required this.repository,
    required this.storage,
  }) : super(AppAuthenticationInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await repository.initialize();
      final tokens = await storage.getTokens();
      if (tokens != null) {
        emit(AppAuthenticated(tokens: tokens));
      } else {
        emit(AppUnauthenticated());
      }
    } catch (e) {
      emit(AppUnauthenticatedFailed(e));
    }
  }

  Future<void> authenticateWithGoogle() async {
    emit(AppAuthenticating());

    try {
      final tokens = await repository.authenticateWithGoogle();
      await storage.saveTokens(tokens);
      emit(AppAuthenticated(tokens: tokens));
    } on GoogleSignInCancelledByUser {
      emit(AppUnauthenticated());
    } catch (e) {
      emit(AppUnauthenticatedFailed(e));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AppAuthenticating());

    try {
      final tokens = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      await storage.saveTokens(tokens);
      emit(AppAuthenticated(tokens: tokens));
    } catch (e) {
      emit(AppUnauthenticatedFailed(e));
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AppAuthenticating());

    try {
      final tokens = await repository.registerWithEmail(
        email: email,
        password: password,
      );
      await storage.saveTokens(tokens);
      emit(AppAuthenticated(tokens: tokens));
    } catch (e) {
      emit(AppUnauthenticatedFailed(e));
    }
  }

  Future<void> onSignedOut() async {
    await storage.clearTokens();
    emit(AppUnauthenticatedSignedOut());
  }
}
