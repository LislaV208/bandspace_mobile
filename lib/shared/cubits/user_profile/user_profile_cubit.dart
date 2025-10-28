import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/shared/utils/error_logger.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/repositories/account_repository.dart';

/// Cubit zarządzający stanem profilu użytkownika
class UserProfileCubit extends Cubit<UserProfileState> {
  final AccountRepository userRepository;

  UserProfileCubit({
    required this.userRepository,
  }) : super(const UserProfileInitial());

  StreamSubscription<User>? _profileSubscription;

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }

  /// Ładuje profil użytkownika
  Future<void> loadProfile() async {
    emit(const UserProfileLoading());

    _profileSubscription =
        userRepository.getProfile().listen((user) {
          emit(UserProfileLoadSuccess(user));
        })..onError((error) {
          emit(UserProfileLoadFailure(getErrorMessage(error)));
        });
  }

  /// Odświeża profil użytkownika
  Future<void> refreshProfile() async {
    await userRepository.refreshProfile();
  }

  void startEditingName() {
    if (state is UserProfileLoadSuccess) {
      final currentState = state as UserProfileLoadSuccess;
      final user = currentState.user;
      emit(UserProfileEditingName(user));
    }
  }

  Future<void> submitEditingName(String name) async {
    if (state is UserProfileEditingName) {
      final currentState = state as UserProfileEditingName;
      final user = currentState.user;

      emit(UserProfileEditNameSubmitting(user));

      try {
        await userRepository.updateProfile(name: name.isNotEmpty ? name : null);

        await refreshProfile();
      } catch (e, stackTrace) {
        logError(
          e,
          stackTrace: stackTrace,
          hint: 'Failed to update user profile name',
        );
        emit(UserProfileEditNameFailure(user, getErrorMessage(e)));
      }
    }
  }

  Future<void> deleteAccount() async {
    if (state is UserProfileLoadSuccess) {
      final currentState = state as UserProfileLoadSuccess;
      final user = currentState.user;

      emit(UserProfileDeleteLoading(user));

      try {
        await userRepository.deleteAccount();
        emit(const UserProfileDeleteSuccess());
      } catch (e, stackTrace) {
        logError(
          e,
          stackTrace: stackTrace,
          hint: 'Failed to delete user account',
        );
        emit(UserProfileDeleteFailure(user, getErrorMessage(e)));
      }
    }
  }
}
