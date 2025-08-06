import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

sealed class ProjectInvitationsState extends Equatable {
  const ProjectInvitationsState();

  @override
  List<Object?> get props => [];
}

/// Base class for states that have access to invitations list
abstract class ProjectInvitationsWithData extends ProjectInvitationsState {
  final List<ProjectInvitation> invitations;

  const ProjectInvitationsWithData(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class ProjectInvitationsInitial extends ProjectInvitationsState {
  const ProjectInvitationsInitial();
}

class ProjectInvitationsLoading extends ProjectInvitationsState {
  const ProjectInvitationsLoading();
}

class ProjectInvitationsLoadSuccess extends ProjectInvitationsWithData {
  const ProjectInvitationsLoadSuccess(super.invitations);
}

class ProjectInvitationsLoadFailure extends ProjectInvitationsState {
  final String? message;

  const ProjectInvitationsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectInvitationsSending extends ProjectInvitationsWithData {
  const ProjectInvitationsSending(super.invitations);
}

class ProjectInvitationsSendSuccess extends ProjectInvitationsWithData {
  final String message;

  const ProjectInvitationsSendSuccess({
    required this.message,
    required List<ProjectInvitation> invitations,
  }) : super(invitations);

  @override
  List<Object?> get props => [message, invitations];
}

class ProjectInvitationsSendFailure extends ProjectInvitationsWithData {
  final String? message;

  const ProjectInvitationsSendFailure({
    required this.message,
    required List<ProjectInvitation> invitations,
  }) : super(invitations);

  @override
  List<Object?> get props => [message, invitations];
}

class ProjectInvitationsCanceling extends ProjectInvitationsWithData {
  const ProjectInvitationsCanceling(super.invitations);
}

class ProjectInvitationsCancelSuccess extends ProjectInvitationsWithData {
  const ProjectInvitationsCancelSuccess(super.invitations);
}

class ProjectInvitationsCancelFailure extends ProjectInvitationsWithData {
  final String? message;

  const ProjectInvitationsCancelFailure({
    required this.message,
    required List<ProjectInvitation> invitations,
  }) : super(invitations);

  @override
  List<Object?> get props => [message, invitations];
}
