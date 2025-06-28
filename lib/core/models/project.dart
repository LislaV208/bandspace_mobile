
import 'package:bandspace_mobile/core/models/project_user.dart';
import 'package:bandspace_mobile/core/models/user.dart';

/// Model danych projektu muzycznego
class Project {
  final int id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProjectUser> projectUsers;

  Project({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.projectUsers,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final projectUsers = <ProjectUser>[];
    if (json['projectUsers'] != null && json['projectUsers'] is List) {
      for (final projectUserJson in json['projectUsers']) {
        projectUsers.add(ProjectUser.fromJson(projectUserJson));
      }
    }

    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      projectUsers: projectUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'projectUsers': projectUsers.map((pu) => pu.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.projectUsers.length == projectUsers.length;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, slug, createdAt, updatedAt, projectUsers.length);
  }

  /// Pobiera liczbę członków projektu
  int get membersCount => projectUsers.length;

  /// Pobiera listę użytkowników należących do projektu
  List<User> get members => projectUsers.map((pu) => pu.user).toList();

  /// Sprawdza czy użytkownik jest członkiem projektu
  bool isMember(int userId) {
    return projectUsers.any((pu) => pu.userId == userId);
  }
}

/// Rozszerzony model projektu dla widoku dashboardu
/// Ponieważ backend nie obsługuje jeszcze członków projektów,
/// używamy podstawowego modelu Project z domyślnymi wartościami
typedef DashboardProject = Project;
