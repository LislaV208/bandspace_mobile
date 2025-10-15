import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/track.dart';

sealed class TrackDetailState extends Equatable {
  final Track track;
  const TrackDetailState(this.track);

  @override
  List<Object?> get props => [track];

  TrackDetailState copyWith(Track track);
}

class TrackDetailLoaded extends TrackDetailState {
  const TrackDetailLoaded(super.track);

  @override
  TrackDetailState copyWith(Track track) => TrackDetailLoaded(track);
}

class TrackDetailUpdating extends TrackDetailState {
  const TrackDetailUpdating(super.track);

  @override
  TrackDetailState copyWith(Track track) => TrackDetailUpdating(track);
}

class TrackDetailUpdateSuccess extends TrackDetailState {
  const TrackDetailUpdateSuccess(super.track);

  @override
  TrackDetailState copyWith(Track track) => TrackDetailUpdateSuccess(track);
}

class TrackDetailUpdateFailure extends TrackDetailState {
  final String message;

  const TrackDetailUpdateFailure({
    required this.message,
    required Track track,
  }) : super(track);

  @override
  List<Object?> get props => [message, track];

  @override
  TrackDetailState copyWith(Track track) => TrackDetailUpdateFailure(
    message: message,
    track: track,
  );
}

class TrackDetailDeleting extends TrackDetailState {
  const TrackDetailDeleting(super.track);

  @override
  TrackDetailState copyWith(Track track) => TrackDetailDeleting(track);
}

class TrackDetailDeleteSuccess extends TrackDetailState {
  const TrackDetailDeleteSuccess(super.track);

  @override
  TrackDetailState copyWith(Track track) => TrackDetailDeleteSuccess(track);
}

class TrackDetailDeleteFailure extends TrackDetailState {
  final String message;

  const TrackDetailDeleteFailure(
    this.message,
    super.track,
  );

  @override
  List<Object?> get props => [message, track];

  @override
  TrackDetailState copyWith(Track track) => TrackDetailDeleteFailure(
    message,
    track,
  );
}

class TrackDetailError extends TrackDetailState {
  final String message;

  const TrackDetailError(this.message, super.track);

  @override
  List<Object?> get props => [message, track];

  @override
  TrackDetailState copyWith(Track track) => TrackDetailError(message, track);
}
