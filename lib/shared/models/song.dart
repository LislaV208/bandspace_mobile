/// Model danych utworu muzycznego
class Song {
  final int id;
  final String title;
  final DateTime createdAt;
  final int fileCount;
  final bool isPrivate;

  Song({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.fileCount,
    this.isPrivate = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      fileCount: json['file_count'] ?? 0,
      isPrivate: json['is_private'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'file_count': fileCount,
      'is_private': isPrivate,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song &&
        other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.fileCount == fileCount &&
        other.isPrivate == isPrivate;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, createdAt, fileCount, isPrivate);
  }

  /// Zwraca czas utworzenia w formacie względnym
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${_getMonthText(months)} temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${_getDayText(difference.inDays)} temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_getHourText(difference.inHours)} temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_getMinuteText(difference.inMinutes)} temu';
    } else {
      return 'przed chwilą';
    }
  }

  String _getMonthText(int count) {
    if (count == 1) return 'miesiąc';
    if (count >= 2 && count <= 4) return 'miesiące';
    return 'miesięcy';
  }

  String _getDayText(int count) {
    if (count == 1) return 'dzień';
    return 'dni';
  }

  String _getHourText(int count) {
    if (count == 1) return 'godzinę';
    if (count >= 2 && count <= 4) return 'godziny';
    return 'godzin';
  }

  String _getMinuteText(int count) {
    if (count == 1) return 'minutę';
    if (count >= 2 && count <= 4) return 'minuty';
    return 'minut';
  }
}