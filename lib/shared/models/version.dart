import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/audio_file.dart';

class Version extends Equatable {
  final int id;
  final String? category;
  final int? bpm;
  final int durationMs;
  final DateTime createdAt;
  final AudioFile? file;

  const Version({
    required this.id,
    required this.category,
    this.bpm,
    required this.durationMs,
    required this.createdAt,
    required this.file,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      id: json['id'],
      category: json['category'],
      bpm: json['bpm'],
      durationMs: json['durationMs'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      file: json['file'] != null ? AudioFile.fromJson(json['file']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'bpm': bpm,
      'durationMs': durationMs,
      'createdAt': createdAt.toIso8601String(),
      'file': file?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, category, bpm, durationMs, createdAt, file];
}
