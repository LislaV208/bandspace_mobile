/// Model pliku audio powiązanego z utworem
class SongFile {
  final int id;
  final int songId;
  final int fileId;
  final int? duration;
  final DateTime createdAt;
  final AudioFileInfo fileInfo;

  const SongFile({
    required this.id,
    required this.songId,
    required this.fileId,
    this.duration,
    required this.createdAt,
    required this.fileInfo,
  });

  factory SongFile.fromJson(Map<String, dynamic> json) {
    return SongFile(
      id: json['id'],
      songId: json['song_id'],
      fileId: json['file_id'],
      duration: json['duration'],
      createdAt: DateTime.parse(json['created_at']),
      fileInfo: AudioFileInfo.fromJson(json['file']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'song_id': songId,
      'file_id': fileId,
      'duration': duration,
      'created_at': createdAt.toIso8601String(),
      'file': fileInfo.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongFile &&
        other.id == id &&
        other.songId == songId &&
        other.fileId == fileId &&
        other.duration == duration &&
        other.createdAt == createdAt &&
        other.fileInfo == fileInfo;
  }

  @override
  int get hashCode {
    return Object.hash(id, songId, fileId, duration, createdAt, fileInfo);
  }

  /// Zwraca sformatowany czas trwania w formacie MM:SS
  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Zwraca sformatowany rozmiar pliku
  String get formattedSize {
    return fileInfo.formattedSize;
  }

  /// Zwraca czy plik jest plikiem audio
  bool get isAudioFile {
    return fileInfo.isAudioFile;
  }
}

/// Model informacji o pliku audio
class AudioFileInfo {
  final int id;
  final String filename;
  final String fileKey;
  final String mimeType;
  final int size;
  final String? description;
  final int uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AudioFileInfo({
    required this.id,
    required this.filename,
    required this.fileKey,
    required this.mimeType,
    required this.size,
    this.description,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AudioFileInfo.fromJson(Map<String, dynamic> json) {
    return AudioFileInfo(
      id: json['id'],
      filename: json['filename'] ?? '',
      fileKey: json['file_key'] ?? '',
      mimeType: json['mime_type'] ?? '',
      size: json['size'] != null ? int.tryParse(json['size']) ?? 0 : 0,
      description: json['description'],
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'file_key': fileKey,
      'mime_type': mimeType,
      'size': size,
      'description': description,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioFileInfo &&
        other.id == id &&
        other.filename == filename &&
        other.fileKey == fileKey &&
        other.mimeType == mimeType &&
        other.size == size &&
        other.description == description &&
        other.uploadedBy == uploadedBy &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, filename, fileKey, mimeType, size, description, uploadedBy, createdAt, updatedAt);
  }

  /// Zwraca sformatowany rozmiar pliku
  String get formattedSize {
    if (size == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double sizeInBytes = size.toDouble();

    while (sizeInBytes >= 1024 && i < suffixes.length - 1) {
      sizeInBytes /= 1024;
      i++;
    }

    return '${sizeInBytes.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Zwraca czy plik jest plikiem audio
  bool get isAudioFile {
    return mimeType.startsWith('audio/');
  }

  /// Zwraca rozszerzenie pliku
  String get fileExtension {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filename.substring(lastDot + 1).toLowerCase();
  }
}
