import 'package:equatable/equatable.dart';

class SongDownloadUrl extends Equatable {
  final int songId;
  final String url;

  const SongDownloadUrl({
    required this.songId,
    required this.url,
  });

  factory SongDownloadUrl.fromJson(Map<String, dynamic> json) {
    return SongDownloadUrl(
      songId: json['songId'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'url': url,
    };
  }

  @override
  List<Object?> get props => [
    songId,
    url,
  ];
}

class SongListDownloadUrls extends Equatable {
  final List<SongDownloadUrl> songUrls;
  final DateTime expiresAt;

  const SongListDownloadUrls({
    required this.songUrls,
    required this.expiresAt,
  });

  factory SongListDownloadUrls.fromJson(Map<String, dynamic> json) {
    return SongListDownloadUrls(
      songUrls: (json['urls'] as List<dynamic>)
          .map((e) => SongDownloadUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urls': songUrls.map((url) => url.toJson()).toList(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    songUrls,
    expiresAt,
  ];
}
