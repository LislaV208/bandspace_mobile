import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final int id;
  final int projectId;
  final String name;
  final String slug;
  final String? artworkUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Album({
    required this.id,
    required this.projectId,
    required this.name,
    required this.slug,
    this.artworkUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      projectId: json['project_id'],
      name: json['name'],
      slug: json['slug'],
      artworkUrl: json['artwork_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'slug': slug,
      'artwork_url': artworkUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, projectId, name, slug, artworkUrl, createdAt, updatedAt];
}