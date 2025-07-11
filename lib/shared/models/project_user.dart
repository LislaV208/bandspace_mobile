import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych dla relacji projekt-użytkownik
class ProjectUser extends Equatable {
  final int id;
  final int projectId;
  final int userId;
  final User user;

  const ProjectUser({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.user,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    userId,
    user,
  ];

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      user: User.fromMap(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'user': user.toMap(),
    };
  }
}
