import 'package:equatable/equatable.dart';

class SongDownloadUrl extends Equatable {
  final int songId;
  final String url;
  final DateTime expiresAt;

  const SongDownloadUrl({
    required this.songId,
    required this.url,
    required this.expiresAt,
  });

  factory SongDownloadUrl.fromJson(Map<String, dynamic> json) {
    final presignedUrl = json['presignedUrl'];

    return SongDownloadUrl(
      songId: json['songId'],
      url: presignedUrl['url'],
      expiresAt: DateTime.parse(presignedUrl['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'presignedUrl': {
        'url': url,
        'expiresAt': expiresAt.toIso8601String(),
      },
    };
  }

  @override
  List<Object?> get props => [
    songId,
    url,
    expiresAt,
  ];
}
