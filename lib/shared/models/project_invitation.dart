import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

class ProjectInvitation extends Equatable {
  final int id;
  final String? email;
  final Project? project;
  final User? invitedBy;
  final DateTime createdAt;
  final ProjectInvitationStatus status;

  const ProjectInvitation({
    required this.id,
    required this.email,
    required this.project,
    required this.invitedBy,
    required this.createdAt,
    required this.status,
  });

  factory ProjectInvitation.fromJson(Map<String, dynamic> json) {
    return ProjectInvitation(
      id: json['id'],
      email: json['email'],
      project: json['project'] != null
          ? Project.fromJson(json['project'])
          : null,
      invitedBy: json['invitedBy'] != null
          ? User.fromMap(json['invitedBy'])
          : null,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      status: ProjectInvitationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ProjectInvitationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'project': project?.toJson(),
      'invitedBy': invitedBy?.toMap(),
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    project,
    invitedBy,
    createdAt,
    status,
  ];
}

enum ProjectInvitationStatus {
  pending,
  accepted,
  rejected,
}

class InvitationResponse extends Equatable {
  final bool success;
  final String message;
  final ProjectInvitation? invitation;

  const InvitationResponse({
    required this.success,
    required this.message,
    this.invitation,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      success: json['success'],
      message: json['message'],
      invitation: json['invitation'] != null
          ? ProjectInvitation.fromJson(json['invitation'])
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, invitation];
}

class InvitationListResponse extends Equatable {
  final bool success;
  final List<ProjectInvitation> invitations;

  const InvitationListResponse({
    required this.success,
    required this.invitations,
  });

  factory InvitationListResponse.fromJson(Map<String, dynamic> json) {
    return InvitationListResponse(
      success: json['success'],
      invitations: (json['invitations'] as List)
          .map((invitation) => ProjectInvitation.fromJson(invitation))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [success, invitations];
}
