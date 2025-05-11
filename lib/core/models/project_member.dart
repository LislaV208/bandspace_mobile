import 'package:equatable/equatable.dart';

class ProjectMember extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final DateTime? createdAt;

  const ProjectMember({required this.id, this.name, this.email, this.avatarUrl, this.createdAt});

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] ?? '',
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, createdAt];
}
