import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych dla relacji projekt-użytkownik
class ProjectUser {
  final int id;
  final int projectId;
  final int userId;
  final User user;

  ProjectUser({required this.id, required this.projectId, required this.userId, required this.user});

  factory ProjectUser.fromJson(Map<String, dynamic> json) {
    return ProjectUser(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'project_id': projectId, 'user_id': userId, 'user': user.toJson()};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectUser &&
        other.id == id &&
        other.projectId == projectId &&
        other.userId == userId &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(id, projectId, userId, user);
  }
}
