import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoadSuccess extends UserProfileState {
  final User user;

  const UserProfileLoadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UserProfileLoadFailure extends UserProfileState {
  final String message;

  const UserProfileLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileEditingName extends UserProfileLoadSuccess {
  const UserProfileEditingName(super.user);
}

class UserProfileEditNameSubmitting extends UserProfileLoadSuccess {
  const UserProfileEditNameSubmitting(super.user);
}

class UserProfileEditNameFailure extends UserProfileLoadSuccess {
  final String message;

  const UserProfileEditNameFailure(super.user, this.message);

  @override
  List<Object?> get props => [user, message];
}
