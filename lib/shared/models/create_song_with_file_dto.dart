import 'dart:typed_data';

/// DTO dla tworzenia piosenki z plikiem
class CreateSongWithFileDto {
  final String title;
  final String? description;
  final String? lyrics;
  final Uint8List? fileData;
  final String? fileName;
  final String? fileExtension;

  const CreateSongWithFileDto({
    required this.title,
    this.description,
    this.lyrics,
    this.fileData,
    this.fileName,
    this.fileExtension,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'lyrics': lyrics,
      'fileName': fileName,
      'fileExtension': fileExtension,
    };
  }

  factory CreateSongWithFileDto.fromJson(Map<String, dynamic> json) {
    return CreateSongWithFileDto(
      title: json['title'] as String,
      description: json['description'] as String?,
      lyrics: json['lyrics'] as String?,
      fileName: json['fileName'] as String?,
      fileExtension: json['fileExtension'] as String?,
    );
  }
}