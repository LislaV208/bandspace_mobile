import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/track.dart';

abstract class ProjectTracksState extends Equatable {
  const ProjectTracksState();

  @override
  List<Object?> get props => [];
}

class ProjectTracksInitial extends ProjectTracksState {
  const ProjectTracksInitial();
}

class ProjectTracksLoading extends ProjectTracksState {
  const ProjectTracksLoading();
}

class ProjectTracksReady extends ProjectTracksState {
  final List<Track> tracks;

  const ProjectTracksReady(this.tracks);

  @override
  List<Object?> get props => [tracks];
}

class ProjectTracksFiltered extends ProjectTracksReady {
  final List<Track> filteredTracks;

  const ProjectTracksFiltered(super.tracks, this.filteredTracks);

  @override
  List<Object?> get props => [tracks, filteredTracks];
}

class ProjectTracksRefreshing extends ProjectTracksReady {
  const ProjectTracksRefreshing(super.tracks);
}

class ProjectTracksRefreshFailure extends ProjectTracksReady {
  final String message;

  const ProjectTracksRefreshFailure(super.tracks, this.message);

  @override
  List<Object?> get props => [tracks, message];
}

class ProjectTracksLoadFailure extends ProjectTracksState {
  final String message;

  const ProjectTracksLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
