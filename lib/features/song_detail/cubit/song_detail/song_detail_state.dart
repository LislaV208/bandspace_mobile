import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

class SongDetailState extends Equatable {
  final List<Song> songs;
  final Song currentSong;

  const SongDetailState(this.songs, this.currentSong);

  @override
  List<Object?> get props => [songs, currentSong];
}
