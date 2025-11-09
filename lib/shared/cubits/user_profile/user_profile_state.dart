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
  List<Object?> get props => [...super.props, user];
}

class UserProfileLoadFailure extends UserProfileState {
  final Object error;

  const UserProfileLoadFailure(this.error);

  @override
  List<Object?> get props => [...super.props, error];
}

class UserProfileEditingName extends UserProfileLoadSuccess {
  const UserProfileEditingName(super.user);
}

class UserProfileEditNameSubmitting extends UserProfileLoadSuccess {
  const UserProfileEditNameSubmitting(super.user);
}

class UserProfileEditNameFailure extends UserProfileLoadSuccess {
  final Object error;

  const UserProfileEditNameFailure(super.user, this.error);

  @override
  List<Object?> get props => [...super.props, error];
}

class UserProfileDeleteLoading extends UserProfileLoadSuccess {
  const UserProfileDeleteLoading(super.user);
}

class UserProfileDeleteSuccess extends UserProfileState {
  const UserProfileDeleteSuccess();
}

class UserProfileDeleteFailure extends UserProfileLoadSuccess {
  final Object error;

  const UserProfileDeleteFailure(super.user, this.error);

  @override
  List<Object?> get props => [...super.props, error];
}

class UserSigningOut extends UserProfileLoadSuccess {
  const UserSigningOut(super.user);
}

class UserSignedOut extends UserProfileLoadSuccess {
  const UserSignedOut(super.user);
}

class UserSigningOutError extends UserProfileLoadSuccess {
  final Object error;
  const UserSigningOutError(this.error, super.user);

  @override
  List<Object?> get props => [...super.props, error];
}
