import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/shared/models/track.dart';

enum FetchStatus { initial, loading, refreshing, success, failure }

enum PlayerUiStatus { idle, loading, playing, paused, completed, error }

class TrackPlayerState extends Equatable {
  // Stan pobierania danych z API
  final FetchStatus fetchStatus;
  final String? errorMessage;

  // Dane
  final List<Track> tracks;
  final int currentTrackIndex;

  // Stan odtwarzacza (bezpośrednio z just_audio)
  final PlayerUiStatus playerUiStatus;
  final Duration currentPosition;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final bool isSeeking;
  final Duration? seekPosition;
  final LoopMode loopMode;
  final bool hasNext;
  final bool hasPrevious;

  const TrackPlayerState({
    this.fetchStatus = FetchStatus.initial,
    this.errorMessage,
    this.tracks = const [],
    this.currentTrackIndex = 0,
    this.playerUiStatus = PlayerUiStatus.idle,
    this.currentPosition = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isSeeking = false,
    this.seekPosition,
    this.loopMode = LoopMode.off,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  // Wygodne gettery
  Track? get currentTrack =>
      tracks.isNotEmpty && currentTrackIndex < tracks.length
      ? tracks[currentTrackIndex]
      : null;

  String? get currentAudioUrl => currentTrack?.mainVersion?.file?.downloadUrl;

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    // Podczas przesuwania użyj seekPosition, w przeciwnym razie currentPosition
    final position = isSeeking && seekPosition != null ? seekPosition! : currentPosition;

    return position.inMilliseconds / totalDuration.inMilliseconds;
  }

  TrackPlayerState copyWith({
    FetchStatus? fetchStatus,
    String? errorMessage,
    List<Track>? tracks,
    int? currentTrackIndex,
    PlayerUiStatus? playerUiStatus,
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
    bool? isSeeking,
    Duration? seekPosition,
    LoopMode? loopMode,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return TrackPlayerState(
      fetchStatus: fetchStatus ?? this.fetchStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      tracks: tracks ?? this.tracks,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      playerUiStatus: playerUiStatus ?? this.playerUiStatus,
      currentPosition: currentPosition ?? this.currentPosition,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isSeeking: isSeeking ?? this.isSeeking,
      seekPosition: seekPosition ?? this.seekPosition,
      loopMode: loopMode ?? this.loopMode,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  @override
  List<Object?> get props => [
    fetchStatus,
    errorMessage,
    tracks,
    currentTrackIndex,
    playerUiStatus,
    currentPosition,
    bufferedPosition,
    totalDuration,
    isSeeking,
    seekPosition,
    loopMode,
    hasNext,
    hasPrevious,
  ];
}
