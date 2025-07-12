import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'audio_player_state.dart';

/// Stan odtwarzacza audio z obsługą playlist.
/// Rozszerza podstawowy AudioPlayerState o funkcjonalności playlist.
class PlaylistAudioPlayerState extends AudioPlayerState {
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

  const PlaylistAudioPlayerState({
    // Pola z bazowego AudioPlayerState
    super.status,
    super.currentUrl,
    super.currentPosition,
    super.totalDuration,
    super.errorMessage,
    super.isReady,
    super.bufferedPosition,
    super.isSeeking,
    super.seekPosition,
    // Nowe pola dla playlist
    this.playlist = const [],
    this.currentIndex,
    this.isShuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.hasPlaylist = false,
  });

  /// Aktualnie odtwarzany URL (z playlist lub pojedynczy)
  String? get currentPlayingUrl {
    if (hasPlaylist && currentIndex != null && currentIndex! < playlist.length) {
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
  @override
  PlaylistAudioPlayerState copyWith({
    PlayerStatus? status,
    Value<String?>? currentUrl,
    Duration? currentPosition,
    Duration? totalDuration,
    Value<String?>? errorMessage,
    bool? isReady,
    Duration? bufferedPosition,
    bool? isSeeking,
    Value<Duration?>? seekPosition,
    // Nowe pola dla playlist
    List<String>? playlist,
    Value<int?>? currentIndex,
    bool? isShuffleEnabled,
    LoopMode? loopMode,
    bool? hasPlaylist,
  }) {
    return PlaylistAudioPlayerState(
      // Pola z bazowego stanu
      status: status ?? this.status,
      currentUrl: currentUrl != null ? currentUrl.value : this.currentUrl,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage != null ? errorMessage.value : this.errorMessage,
      isReady: isReady ?? this.isReady,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isSeeking: isSeeking ?? this.isSeeking,
      seekPosition: seekPosition != null ? seekPosition.value : this.seekPosition,
      // Nowe pola
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex != null ? currentIndex.value : this.currentIndex,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      hasPlaylist: hasPlaylist ?? this.hasPlaylist,
    );
  }

  @override
  List<Object?> get props => [
    // Pola z bazowego stanu
    status,
    currentUrl,
    currentPosition,
    totalDuration,
    errorMessage,
    isReady,
    bufferedPosition,
    isSeeking,
    seekPosition,
    // Nowe pola
    playlist,
    currentIndex,
    isShuffleEnabled,
    loopMode,
    hasPlaylist,
  ];
}