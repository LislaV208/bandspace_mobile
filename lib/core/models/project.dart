import 'package:bandspace_mobile/core/models/project_member.dart';

/// Model danych projektu muzycznego
class Project {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({required this.id, required this.name, this.createdAt, this.updatedAt});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Rozszerzony model projektu zawierający dodatkowe dane dla widoku dashboardu
class DashboardProject extends Project {
  final int membersCount;
  final List<ProjectMember> members;

  DashboardProject({
    required super.id,
    required super.name,
    super.createdAt,
    super.updatedAt,
    required this.membersCount,
    required this.members,
  });

  factory DashboardProject.fromJson(Map<String, dynamic> json) {
    // Pobierz podstawowe dane projektu
    final project = Project.fromJson(json);

    // Pobierz liczbę członków
    final membersCount = json['members_count'] ?? 0;

    // Pobierz członków projektu
    final members = <ProjectMember>[];
    if (json['members'] != null && json['members'] is List) {
      for (final memberJson in json['members']) {
        members.add(ProjectMember.fromJson(memberJson));
      }
    }

    return DashboardProject(
      id: project.id,
      name: project.name,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      membersCount: membersCount,
      members: members,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['members_count'] = membersCount;
    json['members'] = members.map((member) => member.toJson()).toList();
    return json;
  }
}
