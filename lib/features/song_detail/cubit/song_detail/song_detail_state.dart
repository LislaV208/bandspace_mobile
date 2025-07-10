import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

class SongDetailState extends Equatable {
  final Song song;
  const SongDetailState(this.song);

  @override
  List<Object?> get props => [song];
}

class SongDetailLoadFailure extends SongDetailState {
  final String message;

  const SongDetailLoadFailure(super.song, this.message);

  @override
  List<Object?> get props => [song, message];
}
