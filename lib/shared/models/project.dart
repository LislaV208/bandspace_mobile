import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych projektu muzycznego
class Project extends Equatable {
  final int id;
  final String name;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<User> users;

  const Project({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    required this.users,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    createdAt,
    updatedAt,
    users,
  ];

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'users': users.map((pu) => pu.toJson()).toList(),
    };
  }

  /// Sprawdza czy użytkownik jest członkiem projektu
  bool isMember(int userId) {
    return users.any((pu) => pu.id == userId);
  }
}
