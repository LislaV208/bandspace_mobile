import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final int id;
  final int projectId;
  final int? albumId;
  final int createdById;
  final String title;
  final String slug;
  final int? bpm;
  final int? mainVersionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Track({
    required this.id,
    required this.projectId,
    this.albumId,
    required this.createdById,
    required this.title,
    required this.slug,
    this.bpm,
    this.mainVersionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      projectId: json['project_id'],
      albumId: json['album_id'],
      createdById: json['created_by_id'],
      title: json['title'],
      slug: json['slug'],
      bpm: json['bpm'],
      mainVersionId: json['main_version_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'album_id': albumId,
      'created_by_id': createdById,
      'title': title,
      'slug': slug,
      'bpm': bpm,
      'main_version_id': mainVersionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, projectId, albumId, createdById, title, slug, bpm, mainVersionId, createdAt, updatedAt];
}