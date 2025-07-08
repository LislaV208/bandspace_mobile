/// Model szczegółowych danych utworu muzycznego
class SongDetail {
  final int id;
  final String title;
  final String slug;
  final String? notes;
  final int? duration;
  final int? bpm;
  final String? key;
  final String? lyrics;
  final int projectId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SongDetail({
    required this.id,
    required this.title,
    required this.slug,
    this.notes,
    this.duration,
    this.bpm,
    this.key,
    this.lyrics,
    required this.projectId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SongDetail.fromJson(Map<String, dynamic> json) {
    return SongDetail(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      notes: json['notes'],
      duration: json['duration'],
      bpm: json['bpm'],
      key: json['key'],
      lyrics: json['lyrics'],
      projectId: json['project_id'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'notes': notes,
      'duration': duration,
      'bpm': bpm,
      'key': key,
      'lyrics': lyrics,
      'project_id': projectId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongDetail &&
        other.id == id &&
        other.title == title &&
        other.slug == slug &&
        other.notes == notes &&
        other.duration == duration &&
        other.bpm == bpm &&
        other.key == key &&
        other.lyrics == lyrics &&
        other.projectId == projectId &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      slug,
      notes,
      duration,
      bpm,
      key,
      lyrics,
      projectId,
      createdBy,
      createdAt,
      updatedAt,
    );
  }

  /// Zwraca sformatowany czas trwania w formacie MM:SS
  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Zwraca czy utwór ma wszystkie podstawowe metadane
  bool get hasCompleteMetadata {
    return duration != null && bpm != null && key != null;
  }
}