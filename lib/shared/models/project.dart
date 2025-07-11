import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project_user.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych projektu muzycznego
class Project extends Equatable {
  final int id;
  final String name;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ProjectUser>? projectUsers;

  const Project({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.projectUsers,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    createdAt,
    updatedAt,
    projectUsers,
  ];

  factory Project.fromJson(Map<String, dynamic> json) {
    // final projectUsers = <ProjectUser>[];
    // if (json['projectUsers'] != null && json['projectUsers'] is List) {
    //   for (final projectUserJson in json['projectUsers']) {
    //     projectUsers.add(ProjectUser.fromJson(projectUserJson));
    //   }
    // }

    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      projectUsers: json['projectUsers'] != null
          ? (json['projectUsers'] as List<dynamic>)
                .map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'projectUsers': projectUsers?.map((pu) => pu.toJson()).toList(),
    };
  }

  /// Pobiera liczbę członków projektu
  int get membersCount => projectUsers?.length ?? 0;

  /// Pobiera listę użytkowników należących do projektu
  List<User> get members => projectUsers?.map((pu) => pu.user).toList() ?? [];

  /// Sprawdza czy użytkownik jest członkiem projektu
  bool isMember(int userId) {
    return projectUsers?.any((pu) => pu.userId == userId) ?? false;
  }
}
