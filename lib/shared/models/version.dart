import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/audio_file.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

enum VersionCategory {
  idea('Pomysł'),
  attempt('Próba'),
  demo('Demo'),
  mix('Miks'),
  master('Master');

  const VersionCategory(this.displayName);
  final String displayName;

  static VersionCategory? fromString(String? value) {
    if (value == null) return null;
    for (final category in VersionCategory.values) {
      if (category.displayName == value) {
        return category;
      }
    }
    return null;
  }
}

class Version extends Equatable {
  final int id;
  final VersionCategory? category;
  final int? bpm;
  final int? durationMs;
  final DateTime createdAt;
  final AudioFile? file;
  final User? uploader;

  const Version({
    required this.id,
    this.category,
    this.bpm,
    this.durationMs,
    required this.createdAt,
    this.file,
    this.uploader,
  });

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
      id: json['id'],
      category: VersionCategory.fromString(json['category']),
      bpm: json['bpm'],
      durationMs: json['durationMs'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      file: json['file'] != null ? AudioFile.fromJson(json['file']) : null,
      uploader: json['uploader'] != null ? User.fromJson(json['uploader']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category?.displayName,
      'bpm': bpm,
      'durationMs': durationMs,
      'createdAt': createdAt.toIso8601String(),
      'file': file?.toJson(),
      'uploader': uploader?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        category,
        bpm,
        durationMs,
        createdAt,
        file,
        uploader,
      ];
}
