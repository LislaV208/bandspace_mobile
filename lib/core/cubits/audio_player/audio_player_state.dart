import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Stan odtwarzacza audio.
class AudioPlayerState extends Equatable {
  /// Aktualny status operacyjny odtwarzacza.
  final PlayerStatus status;

  /// URL aktualnie załadowanego lub ładowanego pliku audio.
  final String? currentUrl;

  /// Aktualna pozycja głowicy odtwarzającej.
  final Duration currentPosition;

  /// Całkowity czas trwania załadowanego pliku audio.
  final Duration totalDuration;

  /// Komunikat o błędzie, jeśli wystąpił.
  final String? errorMessage;

  /// Czy plik jest gotowy do odtworzenia (załadowany i zdekodowany).
  final bool isReady;

  /// Pozycja do której został zbuforowany audio (w Duration).
  final Duration bufferedPosition;

  /// Czy użytkownik obecnie przesuwa suwak.
  final bool isSeeking;

  /// Tymczasowa pozycja suwaka podczas przesuwania.
  final Duration? seekPosition;

  /// Lista URL-i w playlist
  final List<String> playlist;

  /// Indeks aktualnie odtwarzanego utworu w playlist
  final int? currentIndex;

  /// Czy tryb shuffle jest włączony
  final bool isShuffleEnabled;

  /// Tryb zapętlenia
  final LoopMode loopMode;

  /// Czy playlist jest załadowana
  final bool hasPlaylist;

  /// Postęp pobierania aktualnego pliku (0.0 - 1.0)
  final double downloadProgress;

  /// Czy loading został zainicjowany przez akcję użytkownika (play/pause)
  final bool isUserInitiatedLoading;

  const AudioPlayerState({
    this.status = PlayerStatus.idle,
    this.currentUrl,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
    this.isReady = false,
    this.bufferedPosition = Duration.zero,
    this.isSeeking = false,
    this.seekPosition,
    this.playlist = const [],
    this.currentIndex,
    this.isShuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.hasPlaylist = false,
    this.downloadProgress = 0.0,
    this.isUserInitiatedLoading = false,
  });

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    // Podczas przesuwania użyj seekPosition, w przeciwnym razie currentPosition
    final position = isSeeking && seekPosition != null
        ? seekPosition!
        : currentPosition;
    return position.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// Aktualnie odtwarzany URL (z playlist lub pojedynczy)
  String? get currentPlayingUrl {
    if (hasPlaylist &&
        currentIndex != null &&
        currentIndex! < playlist.length) {
      return playlist[currentIndex!];
    }
    return currentUrl;
  }

  /// Czy możemy przejść do następnego utworu
  bool get canPlayNext {
    if (!hasPlaylist) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex != null && currentIndex! < playlist.length - 1;
  }

  /// Czy możemy przejść do poprzedniego utworu
  bool get canPlayPrevious {
    if (!hasPlaylist) return false;
    if (loopMode == LoopMode.all) return true;
    return currentIndex != null && currentIndex! > 0;
  }

  /// Progress playlist (0.0 - 1.0)
  double get playlistProgress {
    if (!hasPlaylist || playlist.isEmpty || currentIndex == null) return 0.0;

    final trackProgress = currentIndex! / playlist.length;
    final currentTrackProgress = progress / playlist.length;

    return trackProgress + currentTrackProgress;
  }

  /// Tworzy kopię stanu, modyfikując tylko wybrane pola.
  AudioPlayerState copyWith({
    PlayerStatus? status,
    Value<String?>? currentUrl,
    Duration? currentPosition,
    Duration? totalDuration,
    Value<String?>? errorMessage,
    bool? isReady,
    Duration? bufferedPosition,
    bool? isSeeking,
    Value<Duration?>? seekPosition,
    List<String>? playlist,
    Value<int?>? currentIndex,
    bool? isShuffleEnabled,
    LoopMode? loopMode,
    bool? hasPlaylist,
    double? downloadProgress,
    bool? isUserInitiatedLoading,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentUrl: currentUrl != null ? currentUrl.value : this.currentUrl,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
      isReady: isReady ?? this.isReady,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isSeeking: isSeeking ?? this.isSeeking,
      seekPosition: seekPosition != null
          ? seekPosition.value
          : this.seekPosition,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex != null
          ? currentIndex.value
          : this.currentIndex,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      hasPlaylist: hasPlaylist ?? this.hasPlaylist,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isUserInitiatedLoading: isUserInitiatedLoading ?? this.isUserInitiatedLoading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUrl,
    currentPosition,
    totalDuration,
    errorMessage,
    isReady,
    bufferedPosition,
    isSeeking,
    seekPosition,
    playlist,
    currentIndex,
    isShuffleEnabled,
    loopMode,
    hasPlaylist,
    downloadProgress,
    isUserInitiatedLoading,
  ];

  @override
  String toString() {
    return 'AudioPlayerState{'
        'status: $status, '
        'currentUrl: $currentUrl, '
        'currentPosition: $currentPosition, '
        'totalDuration: $totalDuration, '
        'errorMessage: $errorMessage, '
        'isReady: $isReady, '
        'bufferedPosition: $bufferedPosition, '
        'isSeeking: $isSeeking, '
        'seekPosition: $seekPosition, '
        'playlist: $playlist, '
        'currentIndex: $currentIndex, '
        'isShuffleEnabled: $isShuffleEnabled, '
        'loopMode: $loopMode, '
        'hasPlaylist: $hasPlaylist, '
        'downloadProgress: $downloadProgress, '
        'isUserInitiatedLoading: $isUserInitiatedLoading, '
        '}';
  }
}
