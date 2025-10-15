import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final int authorId;
  final int versionId;
  final String text;
  final int? timestampMs;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Comment({
    required this.id,
    required this.authorId,
    required this.versionId,
    required this.text,
    this.timestampMs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      authorId: json['author_id'],
      versionId: json['version_id'],
      text: json['text'],
      timestampMs: json['timestamp_ms'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'version_id': versionId,
      'text': text,
      'timestamp_ms': timestampMs,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, authorId, versionId, text, timestampMs, createdAt, updatedAt];
}