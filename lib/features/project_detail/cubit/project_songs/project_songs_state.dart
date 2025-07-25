import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

abstract class ProjectSongsState extends Equatable {
  const ProjectSongsState();

  @override
  List<Object?> get props => [];
}

class ProjectSongsInitial extends ProjectSongsState {
  const ProjectSongsInitial();
}

class ProjectSongsLoading extends ProjectSongsState {
  const ProjectSongsLoading();
}

class ProjectSongsReady extends ProjectSongsState {
  final List<Song> songs;

  const ProjectSongsReady(this.songs);

  @override
  List<Object?> get props => [songs];
}

class ProjectSongsFiltered extends ProjectSongsReady {
  final List<Song> filteredSongs;

  const ProjectSongsFiltered(super.songs, this.filteredSongs);

  @override
  List<Object?> get props => [songs, filteredSongs];
}

class ProjectSongsRefreshing extends ProjectSongsReady {
  const ProjectSongsRefreshing(super.songs);
}

class ProjectSongsRefreshFailure extends ProjectSongsReady {
  final String message;

  const ProjectSongsRefreshFailure(super.songs, this.message);

  @override
  List<Object?> get props => [songs, message];
}

class ProjectSongsLoadFailure extends ProjectSongsState {
  final String message;

  const ProjectSongsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
