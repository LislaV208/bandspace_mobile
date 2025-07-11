import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/repositories/user_repository.dart';

/// Cubit zarządzający stanem profilu użytkownika
class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository userRepository;

  UserProfileCubit({
    required this.userRepository,
  }) : super(const UserProfileInitial()) {
    loadProfile();
  }

  late StreamSubscription<User> _profileSubscription;

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  /// Ładuje profil użytkownika
  Future<void> loadProfile() async {
    emit(const UserProfileLoading());

    _profileSubscription =
        userRepository.getProfile().listen((user) {
          emit(UserProfileLoadSuccess(user));
        })..onError((error) {
          emit(UserProfileLoadFailure(error.toString()));
        });
  }

  /// Odświeża profil użytkownika
  Future<void> refreshProfile() async {
    emit(const UserProfileLoading());
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
        await userRepository.updateProfile(name: name);

        await refreshProfile();
      } catch (e) {
        emit(UserProfileEditNameFailure(user, e.toString()));
      }
    }
  }
}
