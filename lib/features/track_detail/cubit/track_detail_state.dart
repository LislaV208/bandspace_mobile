import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/track.dart';

sealed class TrackDetailState extends Equatable {
  const TrackDetailState();

  @override
  List<Object?> get props => [];
}

/// Klasa bazowa dla stanów zawierających dane ścieżki
abstract class TrackDetailWithData extends TrackDetailState {
  final Track track;

  const TrackDetailWithData(this.track);

  @override
  List<Object?> get props => [track];
}

class TrackDetailInitial extends TrackDetailState {
  const TrackDetailInitial();
}

class TrackDetailLoading extends TrackDetailState {
  const TrackDetailLoading();
}

class TrackDetailLoaded extends TrackDetailWithData {
  const TrackDetailLoaded(super.track);
}

class TrackDetailUpdating extends TrackDetailWithData {
  const TrackDetailUpdating(super.track);
}

class TrackDetailUpdateSuccess extends TrackDetailWithData {
  const TrackDetailUpdateSuccess(super.track);
}

class TrackDetailUpdateFailure extends TrackDetailWithData {
  final String message;

  const TrackDetailUpdateFailure({
    required this.message,
    required Track track,
  }) : super(track);

  @override
  List<Object?> get props => [message, track];
}

class TrackDetailDeleting extends TrackDetailWithData {
  const TrackDetailDeleting(super.track);
}

class TrackDetailDeleteSuccess extends TrackDetailState {
  const TrackDetailDeleteSuccess();
}

class TrackDetailDeleteFailure extends TrackDetailWithData {
  final String message;

  const TrackDetailDeleteFailure({
    required this.message,
    required Track track,
  }) : super(track);

  @override
  List<Object?> get props => [message, track];
}

class TrackDetailError extends TrackDetailState {
  final String message;

  const TrackDetailError(this.message);

  @override
  List<Object?> get props => [message];
}