import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

class ProjectInvitation extends Equatable {
  final int id;
  final String? email;
  final Project? project;
  final User? invitedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectInvitationStatus status;

  const ProjectInvitation({
    required this.id,
    required this.email,
    required this.project,
    required this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    updatedAt,
    status,
  ];
}

enum ProjectInvitationStatus {
  pending,
  accepted,
  rejected,
}

