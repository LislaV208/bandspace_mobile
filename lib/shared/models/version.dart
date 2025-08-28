import 'package:equatable/equatable.dart';
import 'package:bandspace_mobile/shared/models/enums/version_category.dart';

class Version extends Equatable {
  final int id;
  final int trackId;
  final int uploaderId;
  final int fileId;
  final String name;
  final VersionCategory category;
  final int durationMs;
  final DateTime createdAt;

  const Version({
    required this.id,
    required this.trackId,
    required this.uploaderId,
    required this.fileId,
    required this.name,
    required this.category,
    required this.durationMs,
    required this.createdAt,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      id: json['id'],
      trackId: json['track_id'],
      uploaderId: json['uploader_id'],
      fileId: json['file_id'],
      name: json['name'],
      category: VersionCategory.values.firstWhere((e) => e.apiValue == json['category']),
      durationMs: json['duration_ms'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track_id': trackId,
      'uploader_id': uploaderId,
      'file_id': fileId,
      'name': name,
      'category': category.apiValue,
      'duration_ms': durationMs,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, trackId, uploaderId, fileId, name, category, durationMs, createdAt];
}