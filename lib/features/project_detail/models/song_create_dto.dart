import 'dart:io';

class SongCreateDto {
  final String title;
  final File file;

  const SongCreateDto({
    required this.title,
    required this.file,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'file': file,
    };
  }
}
