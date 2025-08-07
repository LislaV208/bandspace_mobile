import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych dla relacji projekt-użytkownik
class ProjectMember extends Equatable {
  final int id;
  final DateTime? joinedAt;
  final Project project;
  final User user;
  final User? invitedBy;

  const ProjectMember({
    required this.id,
    required this.joinedAt,
    required this.project,
    required this.user,
    this.invitedBy,
  });

  @override
  List<Object?> get props => [
    id,
    joinedAt,
    project,
    user,
    invitedBy,
  ];

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'],
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : null,
      project: Project.fromJson(json['project']),
      user: User.fromMap(json['user']),
      invitedBy: json['invitedBy'] != null
          ? User.fromMap(json['invitedBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'joinedAt': joinedAt?.toIso8601String(),
      'project': project.toJson(),
      'user': user.toMap(),
      'invitedBy': invitedBy?.toMap(),
    };
  }
}
