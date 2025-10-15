import 'package:equatable/equatable.dart';

class AudioFile extends Equatable {
  final int id;
  final String filename;
  final String mimeType;
  final int size;
  final DateTime createdAt;
  final String? downloadUrl;

  const AudioFile({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    required this.downloadUrl,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      filename: json['filename'],
      mimeType: json['mime_type'],
      size: json['size'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      downloadUrl: json['downloadUrl'],
    );
  }

  factory AudioFile.fromJsonWithUploadedBy(Map<String, dynamic> json) {
    return AudioFile(
      id: json['id'],
      filename: json['filename'],
      mimeType: json['mime_type'],
      size: json['size'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      downloadUrl: json['downloadUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'mime_type': mimeType,
      'size': size,
      'createdAt': createdAt.toIso8601String(),
      'downloadUrl': downloadUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    filename,
    mimeType,
    size,
    createdAt,
    downloadUrl,
  ];
}
