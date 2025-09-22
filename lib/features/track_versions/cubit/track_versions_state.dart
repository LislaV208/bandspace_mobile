import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/version.dart';

sealed class TrackVersionsState extends Equatable {
  const TrackVersionsState();

  @override
  List<Object?> get props => [];
}

abstract class TrackVersionsWithData extends TrackVersionsState {
  final List<Version> versions;

  const TrackVersionsWithData(this.versions);

  @override
  List<Object?> get props => [versions];
}

class TrackVersionsInitial extends TrackVersionsState {
  const TrackVersionsInitial();
}

class TrackVersionsLoading extends TrackVersionsState {
  const TrackVersionsLoading();
}

class TrackVersionsLoaded extends TrackVersionsWithData {
  const TrackVersionsLoaded(super.versions);
}

class TrackVersionsRefreshing extends TrackVersionsWithData {
  const TrackVersionsRefreshing(super.versions);
}

class TrackVersionsError extends TrackVersionsState {
  final String message;

  const TrackVersionsError(this.message);

  @override
  List<Object?> get props => [message];
}