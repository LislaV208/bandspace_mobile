import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

enum PlayerUiStatus { idle, loading, playing, paused, completed, error }

sealed class TrackVersionsState extends Equatable {
  const TrackVersionsState();

  @override
  List<Object?> get props => [];
}

abstract class TrackVersionsWithData extends TrackVersionsState {
  final List<Version> versions;

  // Stan odtwarzacza
  final Version? currentVersion;
  final PlayerUiStatus playerUiStatus;
  final Duration currentPosition;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final bool isSeeking;
  final Duration? seekPosition;

  const TrackVersionsWithData(
    this.versions, {
    this.currentVersion,
    this.playerUiStatus = PlayerUiStatus.idle,
    this.currentPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isSeeking = false,
    this.seekPosition,
  });

  // Wygodne gettery
  String? get currentAudioUrl => currentVersion?.file?.downloadUrl;

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    // Podczas przesuwania użyj seekPosition, w przeciwnym razie currentPosition
    final position = isSeeking && seekPosition != null
        ? seekPosition!
        : currentPosition;

    return position.inMilliseconds / totalDuration.inMilliseconds;
  }

  // Navigation controls dla wersji
  bool get hasNext => versions.isNotEmpty && currentVersion != null &&
      versions.indexOf(currentVersion!) < versions.length - 1;

  bool get hasPrevious => versions.isNotEmpty && currentVersion != null &&
      versions.indexOf(currentVersion!) > 0;

  @override
  List<Object?> get props => [
    versions,
    currentVersion,
    playerUiStatus,
    currentPosition,
    bufferedPosition,
    totalDuration,
    isSeeking,
    seekPosition,
  ];
}

class TrackVersionsInitial extends TrackVersionsState {
  const TrackVersionsInitial();
}

class TrackVersionsLoading extends TrackVersionsState {
  const TrackVersionsLoading();
}

class TrackVersionsLoaded extends TrackVersionsWithData {
  const TrackVersionsLoaded(
    super.versions, {
    super.currentVersion,
    super.playerUiStatus,
    super.currentPosition,
    super.bufferedPosition,
    super.totalDuration,
    super.isSeeking,
    super.seekPosition,
  });

  TrackVersionsLoaded copyWith({
    List<Version>? versions,
    Value<Version?>? currentVersion,
    PlayerUiStatus? playerUiStatus,
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
    bool? isSeeking,
    Value<Duration?>? seekPosition,
  }) {
    return TrackVersionsLoaded(
      versions ?? this.versions,
      currentVersion: currentVersion != null ? currentVersion.value : this.currentVersion,
      playerUiStatus: playerUiStatus ?? this.playerUiStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isSeeking: isSeeking ?? this.isSeeking,
      seekPosition: seekPosition != null ? seekPosition.value : this.seekPosition,
    );
  }
}

class TrackVersionsRefreshing extends TrackVersionsWithData {
  const TrackVersionsRefreshing(
    super.versions, {
    super.currentVersion,
    super.playerUiStatus,
    super.currentPosition,
    super.bufferedPosition,
    super.totalDuration,
    super.isSeeking,
    super.seekPosition,
  });
}

class TrackVersionsError extends TrackVersionsState {
  final String message;

  const TrackVersionsError(this.message);

  @override
  List<Object?> get props => [message];
}