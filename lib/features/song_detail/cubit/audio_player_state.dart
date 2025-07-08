import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/shared/models/cached_audio_file.dart';

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
  
  // Offline-related fields
  final bool isPlayingOffline;
  final Map<int, CacheStatus> cacheStatuses;
  final Map<int, DownloadProgress> downloadProgresses;

  const AudioPlayerState({
    this.status = AudioPlayerStatus.idle,
    this.currentFile,
    this.playlist = const [],
    this.currentIndex = 0,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
    this.errorMessage,
    this.isPlayingOffline = false,
    this.cacheStatuses = const {},
    this.downloadProgresses = const {},
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
    bool? isPlayingOffline,
    Map<int, CacheStatus>? cacheStatuses,
    Map<int, DownloadProgress>? downloadProgresses,
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
      isPlayingOffline: isPlayingOffline ?? this.isPlayingOffline,
      cacheStatuses: cacheStatuses ?? this.cacheStatuses,
      downloadProgresses: downloadProgresses ?? this.downloadProgresses,
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
        other.errorMessage == errorMessage &&
        other.isPlayingOffline == isPlayingOffline &&
        other.cacheStatuses == cacheStatuses &&
        other.downloadProgresses == downloadProgresses;
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
      isPlayingOffline,
      cacheStatuses,
      downloadProgresses,
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

  // =============== OFFLINE-RELATED GETTERS ===============

  /// Sprawdza czy aktualny plik jest dostępny offline
  bool get currentFileIsAvailableOffline {
    if (currentFile == null) return false;
    final status = cacheStatuses[currentFile!.fileId];
    return status?.isAvailableOffline == true;
  }

  /// Sprawdza czy aktualny plik jest w trakcie pobierania
  bool get currentFileIsDownloading {
    if (currentFile == null) return false;
    final status = cacheStatuses[currentFile!.fileId];
    return status?.isDownloading == true;
  }

  /// Sprawdza czy można rozpocząć pobieranie aktualnego pliku
  bool get currentFileCanStartDownload {
    if (currentFile == null) return false;
    final status = cacheStatuses[currentFile!.fileId];
    return status?.canStartDownload != false; // Default to true if no status
  }

  /// Pobiera status cache dla aktualnego pliku
  CacheStatus? get currentFileCacheStatus {
    if (currentFile == null) return null;
    return cacheStatuses[currentFile!.fileId];
  }

  /// Pobiera postęp pobierania dla aktualnego pliku
  DownloadProgress? get currentFileDownloadProgress {
    if (currentFile == null) return null;
    return downloadProgresses[currentFile!.fileId];
  }

  /// Sprawdza czy jakikolwiek plik w playliście jest dostępny offline
  bool get hasOfflineFiles {
    for (final file in playlist) {
      final status = cacheStatuses[file.fileId];
      if (status?.isAvailableOffline == true) {
        return true;
      }
    }
    return false;
  }

  /// Sprawdza czy wszystkie pliki w playliście są dostępne offline
  bool get allFilesAvailableOffline {
    if (playlist.isEmpty) return false;
    for (final file in playlist) {
      final status = cacheStatuses[file.fileId];
      if (status?.isAvailableOffline != true) {
        return false;
      }
    }
    return true;
  }

  /// Liczba plików dostępnych offline w playliście
  int get offlineFileCount {
    int count = 0;
    for (final file in playlist) {
      final status = cacheStatuses[file.fileId];
      if (status?.isAvailableOffline == true) {
        count++;
      }
    }
    return count;
  }

  /// Sprawdza czy są aktywne pobierania
  bool get hasActiveDownloads {
    for (final progress in downloadProgresses.values) {
      if (progress.isDownloading) {
        return true;
      }
    }
    return false;
  }

  /// Liczba aktywnych pobierań
  int get activeDownloadCount {
    int count = 0;
    for (final progress in downloadProgresses.values) {
      if (progress.isDownloading) {
        count++;
      }
    }
    return count;
  }

  /// Sprawdza status cache dla danego pliku
  CacheStatus getCacheStatusForFile(int fileId) {
    return cacheStatuses[fileId] ?? CacheStatus.notCached;
  }

  /// Sprawdza czy dany plik jest dostępny offline
  bool isFileAvailableOffline(int fileId) {
    final status = cacheStatuses[fileId];
    return status?.isAvailableOffline == true;
  }

  /// Sprawdza czy dany plik jest w trakcie pobierania
  bool isFileDownloading(int fileId) {
    final status = cacheStatuses[fileId];
    return status?.isDownloading == true;
  }
}