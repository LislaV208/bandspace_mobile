import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/file.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Model danych utworu muzycznego
class Song extends Equatable {
  final int id;
  final String title;
  final User createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final File file;
  final String? downloadUrl;
  final Duration? duration;
  final int? bpm;
  final String? lyrics;

  const Song({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.file,
    this.downloadUrl,
    this.duration,
    this.bpm,
    this.lyrics,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] ?? '',
      createdBy: User.fromMap(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      file: File.fromJson(json['file']),
      downloadUrl: json['downloadUrl'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      bpm: json['bpm'],
      lyrics: json['lyrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdBy': createdBy.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'file': file.toJson(),
      'downloadUrl': downloadUrl,
      'duration': duration?.inMilliseconds,
      'bpm': bpm,
      'lyrics': lyrics,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdBy,
    createdAt,
    updatedAt,
    file,
    downloadUrl,
    duration,
    bpm,
    lyrics,
  ];
}
