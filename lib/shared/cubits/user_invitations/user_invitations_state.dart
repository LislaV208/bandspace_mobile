import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

sealed class UserInvitationsState extends Equatable {
  const UserInvitationsState();

  @override
  List<Object?> get props => [];
}

class UserInvitationsInitial extends UserInvitationsState {
  const UserInvitationsInitial();
}

class UserInvitationsLoading extends UserInvitationsState {
  const UserInvitationsLoading();
}

class UserInvitationsLoadSuccess extends UserInvitationsState {
  final List<ProjectInvitation> invitations;

  const UserInvitationsLoadSuccess(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class UserInvitationsLoadFailure extends UserInvitationsState {
  final String? message;

  const UserInvitationsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UserInvitationsAccepting extends UserInvitationsState {
  const UserInvitationsAccepting();
}

class UserInvitationsRejecting extends UserInvitationsState {
  const UserInvitationsRejecting();
}

class UserInvitationsActionSuccess extends UserInvitationsState {
  final String message;
  final List<ProjectInvitation> invitations;

  const UserInvitationsActionSuccess({
    required this.message,
    required this.invitations,
  });

  @override
  List<Object?> get props => [message, invitations];
}

class UserInvitationsActionFailure extends UserInvitationsState {
  final String? message;

  const UserInvitationsActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}