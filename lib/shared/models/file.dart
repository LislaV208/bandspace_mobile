import 'package:equatable/equatable.dart';

/// Model informacji o pliku audio
class File extends Equatable {
  final int id;
  final String? filename;
  final String? fileKey;
  final String? mimeType;

  /// W bajtach
  final int? size;
  final String? description;
  final int? uploadedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const File({
    required this.id,
    this.filename,
    this.fileKey,
    this.mimeType,
    this.size,
    this.description,
    this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      filename: json['filename'],
      fileKey: json['file_key'],
      mimeType: json['mime_type'],
      size: json['size'],
      description: json['description'],
      uploadedBy: json['uploaded_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    filename,
    fileKey,
    mimeType,
    size,
    description,
    uploadedBy,
    createdAt,
    updatedAt,
  ];
}
