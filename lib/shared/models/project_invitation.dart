import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

class ProjectInvitation extends Equatable {
  final int id;
  final String email;
  final ProjectInvitationProject project;
  final User invitedBy;
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
      project: ProjectInvitationProject.fromJson(json['project']),
      invitedBy: User.fromMap(json['invited_by']),
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
      'project': project.toJson(),
      'invited_by': invitedBy.toMap(),
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

class ProjectInvitationProject extends Equatable {
  final int id;
  final String name;
  final String slug;

  const ProjectInvitationProject({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProjectInvitationProject.fromJson(Map<String, dynamic> json) {
    return ProjectInvitationProject(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  @override
  List<Object?> get props => [id, name, slug];
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
