import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/song_download_url.dart';

abstract class SongDetailState extends Equatable {
  final List<Song> songs;
  final Song currentSong;

  const SongDetailState(this.songs, this.currentSong);

  @override
  List<Object?> get props => [songs, currentSong];
}

class SongDetailInitial extends SongDetailState {
  const SongDetailInitial(super.songs, super.currentSong);
}

class SongDetailLoadUrls extends SongDetailState {
  const SongDetailLoadUrls(super.songs, super.currentSong);
}

class SongDetailLoadUrlsFailure extends SongDetailState {
  final String message;

  const SongDetailLoadUrlsFailure(
    super.songs,
    super.currentSong,
    this.message,
  );

  @override
  List<Object?> get props => [songs, currentSong, message];
}

class SongDetailLoadUrlsSuccess extends SongDetailState {
  final List<SongDownloadUrl> downloadUrls;

  const SongDetailLoadUrlsSuccess(
    super.songs,
    super.currentSong,
    this.downloadUrls,
  );

  @override
  List<Object?> get props => [songs, currentSong, downloadUrls];
}

class SongDetailReady extends SongDetailState {
  const SongDetailReady(super.songs, super.currentSong);
}
