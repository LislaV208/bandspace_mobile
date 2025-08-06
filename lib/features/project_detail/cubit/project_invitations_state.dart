import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

sealed class ProjectInvitationsState extends Equatable {
  const ProjectInvitationsState();

  @override
  List<Object?> get props => [];
}

class ProjectInvitationsInitial extends ProjectInvitationsState {
  const ProjectInvitationsInitial();
}

class ProjectInvitationsLoading extends ProjectInvitationsState {
  const ProjectInvitationsLoading();
}

class ProjectInvitationsLoadSuccess extends ProjectInvitationsState {
  final List<ProjectInvitation> invitations;

  const ProjectInvitationsLoadSuccess(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class ProjectInvitationsLoadFailure extends ProjectInvitationsState {
  final String? message;

  const ProjectInvitationsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectInvitationsSending extends ProjectInvitationsState {
  const ProjectInvitationsSending();
}

class ProjectInvitationsSendSuccess extends ProjectInvitationsState {
  final String message;
  final List<ProjectInvitation> invitations;

  const ProjectInvitationsSendSuccess({
    required this.message,
    required this.invitations,
  });

  @override
  List<Object?> get props => [message, invitations];
}

class ProjectInvitationsSendFailure extends ProjectInvitationsState {
  final String? message;

  const ProjectInvitationsSendFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectInvitationsCanceling extends ProjectInvitationsState {
  const ProjectInvitationsCanceling();
}

class ProjectInvitationsCancelSuccess extends ProjectInvitationsState {
  final List<ProjectInvitation> invitations;

  const ProjectInvitationsCancelSuccess(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

class ProjectInvitationsCancelFailure extends ProjectInvitationsState {
  final String? message;

  const ProjectInvitationsCancelFailure(this.message);

  @override
  List<Object?> get props => [message];
}
