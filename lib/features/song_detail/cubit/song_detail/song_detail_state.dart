import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

abstract class SongDetailState extends Equatable {
  final Song song;

  const SongDetailState(this.song);

  @override
  List<Object?> get props => [song];
}

class SongDetailInitial extends SongDetailState {
  const SongDetailInitial(super.song);
}

class SongDetailLoading extends SongDetailState {
  const SongDetailLoading(super.song);
}

class SongDetailLoadSuccess extends SongDetailState {
  const SongDetailLoadSuccess(super.song);
}

class SongDetailLoadFailure extends SongDetailState {
  final String message;

  const SongDetailLoadFailure(super.song, this.message);

  @override
  List<Object?> get props => [song, message];
}

class SongFileUrlLoading extends SongDetailLoadSuccess {
  const SongFileUrlLoading(super.song);
}

class SongFileUrlLoadSuccess extends SongDetailLoadSuccess {
  final String url;

  const SongFileUrlLoadSuccess(super.song, this.url);

  @override
  List<Object?> get props => [song, url];
}

class SongFileUrlLoadFailure extends SongDetailLoadSuccess {
  final String message;

  const SongFileUrlLoadFailure(super.song, this.message);

  @override
  List<Object?> get props => [song, message];
}
