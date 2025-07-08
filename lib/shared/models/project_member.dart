import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

class ProjectMember extends Equatable {
  final int id;
  final int projectId;
  final int userId;
  final DateTime? joinedAt;
  final User? invitedBy;
  final User user;

  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    this.joinedAt,
    this.invitedBy,
    required this.user,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at']).toLocal()
          : null,
      invitedBy: json['invited_by'] != null
          ? User.fromJson(json['invited_by'])
          : null,
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'joined_at': joinedAt?.toIso8601String(),
      'invited_by': invitedBy?.toJson(),
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    userId,
    joinedAt,
    invitedBy,
    user,
  ];
}
