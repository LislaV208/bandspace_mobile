import 'package:bandspace_mobile/core/models/song_file.dart';

/// Status odtwarzacza audio
enum AudioPlayerStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

/// Stan odtwarzacza audio
class AudioPlayerState {
  final AudioPlayerStatus status;
  final SongFile? currentFile;
  final List<SongFile> playlist;
  final int currentIndex;
  final Duration currentPosition;
  final Duration totalDuration;
  final double volume;
  final String? errorMessage;

  const AudioPlayerState({
    this.status = AudioPlayerStatus.idle,
    this.currentFile,
    this.playlist = const [],
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    SongFile? currentFile,
    List<SongFile>? playlist,
    int? currentIndex,
    Duration? currentPosition,
    Duration? totalDuration,
    double? volume,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentFile: currentFile ?? this.currentFile,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioPlayerState &&
        other.status == status &&
        other.currentFile == currentFile &&
        other.playlist == playlist &&
        other.currentIndex == currentIndex &&
        other.currentPosition == currentPosition &&
        other.totalDuration == totalDuration &&
        other.volume == volume &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      currentFile,
      playlist,
      currentIndex,
      currentPosition,
      totalDuration,
      volume,
      errorMessage,
    );
  }

  /// Czy odtwarzacz jest w stanie odtwarzania
  bool get isPlaying => status == AudioPlayerStatus.playing;

  /// Czy odtwarzacz jest w stanie pauzy
  bool get isPaused => status == AudioPlayerStatus.paused;

  /// Czy odtwarzacz jest w stanie ładowania
  bool get isLoading => status == AudioPlayerStatus.loading;

  /// Czy odtwarzacz jest w stanie błędu
  bool get hasError => status == AudioPlayerStatus.error;

  /// Czy odtwarzacz jest zatrzymany
  bool get isStopped => status == AudioPlayerStatus.stopped || status == AudioPlayerStatus.idle;

  /// Czy można przejść do następnego utworu
  bool get canGoNext => playlist.isNotEmpty && currentIndex < playlist.length - 1;

  /// Czy można przejść do poprzedniego utworu
  bool get canGoPrevious => playlist.isNotEmpty && currentIndex > 0;

  /// Postęp odtwarzania (0.0 - 1.0)
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }
}