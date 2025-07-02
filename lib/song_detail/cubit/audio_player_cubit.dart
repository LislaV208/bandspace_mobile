import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/models/cached_audio_file.dart';
import 'package:bandspace_mobile/core/repositories/song_repository.dart';
import 'package:bandspace_mobile/core/services/audio_cache_service.dart';
import 'package:bandspace_mobile/song_detail/cubit/audio_player_state.dart';

/// Cubit zarządzający odtwarzaczem audio
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final SongRepository songRepository;
  final AudioCacheService _cacheService;
  final AudioPlayer _audioPlayer;
  final int songId;
  
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  
  // Subskrypcje dla offline cache
  final Map<int, StreamSubscription<DownloadProgress>> _downloadSubscriptions = {};

  AudioPlayerCubit({
    required this.songRepository,
    required this.songId,
    AudioCacheService? cacheService,
  })  : _cacheService = cacheService ?? AudioCacheService(),
        _audioPlayer = AudioPlayer(),
        super(const AudioPlayerState()) {
    _initializePlayer();
  }

  /// Inicjalizuje odtwarzacz i nasłuchuje zmian stanu
  void _initializePlayer() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((playerState) {
      switch (playerState) {
        case PlayerState.playing:
          emit(state.copyWith(status: AudioPlayerStatus.playing));
          break;
        case PlayerState.paused:
          emit(state.copyWith(status: AudioPlayerStatus.paused));
          break;
        case PlayerState.stopped:
          emit(state.copyWith(status: AudioPlayerStatus.stopped));
          break;
        case PlayerState.completed:
          _onTrackCompleted();
          break;
        case PlayerState.disposed:
          emit(state.copyWith(status: AudioPlayerStatus.idle));
          break;
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      emit(state.copyWith(currentPosition: position));
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      emit(state.copyWith(totalDuration: duration));
    });
  }

  /// Ustawia playlistę plików
  Future<void> setPlaylist(List<SongFile> files) async {
    emit(state.copyWith(
      playlist: files,
      currentIndex: 0,
    ));
    
    // Załaduj statusy cache dla wszystkich plików
    await _loadCacheStatuses(files);
  }

  /// Wybiera plik bez odtwarzania
  void selectFile(SongFile file) {
    final fileIndex = state.playlist.indexWhere((f) => f.id == file.id);
    if (fileIndex == -1) {
      // Plik nie jest w playliście, dodaj go
      final newPlaylist = [file];
      emit(state.copyWith(
        playlist: newPlaylist,
        currentIndex: 0,
        currentFile: file,
      ));
    } else {
      emit(state.copyWith(
        currentIndex: fileIndex,
        currentFile: file,
      ));
    }
  }

  /// Odtwarza wybrany plik
  Future<void> playFile(SongFile file) async {
    selectFile(file);
    await _loadAndPlayCurrentFile();
  }

  /// Ładuje i odtwarza aktualny plik
  Future<void> _loadAndPlayCurrentFile() async {
    if (state.currentFile == null) return;

    emit(state.copyWith(
      status: AudioPlayerStatus.loading,
      errorMessage: null,
    ));

    try {
      // Sprawdź czy plik jest dostępny offline
      final localPath = await _cacheService.getLocalPath(state.currentFile!.fileId);
      
      if (localPath != null) {
        // Odtwórz z cache lokalnego
        print('AudioPlayer: Playing from cache: $localPath');
        await _audioPlayer.play(DeviceFileSource(localPath));
        emit(state.copyWith(isPlayingOffline: true));
      } else {
        // Pobierz URL do streamowania i rozpocznij smart caching
        final streamUrl = await songRepository.getFileDownloadUrl(
          songId: songId,
          fileId: state.currentFile!.fileId,
        );

        print('AudioPlayer: Streaming from URL: $streamUrl');
        await _audioPlayer.play(UrlSource(streamUrl));
        emit(state.copyWith(isPlayingOffline: false));

        // Automatyczne cache'owanie w tle (fire-and-forget)
        _startBackgroundCaching(state.currentFile!, streamUrl);
        
        // Opcjonalnie preload następnych plików
        _preloadNextFiles();
      }
    } catch (e) {
      emit(state.copyWith(
        status: AudioPlayerStatus.error,
        errorMessage: 'Błąd podczas ładowania pliku: $e',
      ));
    }
  }

  /// Wznawia lub pauzuje odtwarzanie
  Future<void> playPause() async {
    if (state.isPlaying) {
      await pause();
    } else if (state.isPaused) {
      await resume();
    } else if (state.currentFile != null) {
      await _loadAndPlayCurrentFile();
    }
  }

  /// Pauzuje odtwarzanie
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Wznawia odtwarzanie
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// Zatrzymuje odtwarzanie
  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(state.copyWith(
      status: AudioPlayerStatus.stopped,
      currentPosition: Duration.zero,
    ));
  }

  /// Przechodzi do następnego utworu
  Future<void> next() async {
    if (!state.canGoNext) return;

    final nextIndex = state.currentIndex + 1;
    final nextFile = state.playlist[nextIndex];

    emit(state.copyWith(
      currentIndex: nextIndex,
      currentFile: nextFile,
    ));

    await _loadAndPlayCurrentFile();
  }

  /// Przechodzi do poprzedniego utworu
  Future<void> previous() async {
    if (!state.canGoPrevious) return;

    final previousIndex = state.currentIndex - 1;
    final previousFile = state.playlist[previousIndex];

    emit(state.copyWith(
      currentIndex: previousIndex,
      currentFile: previousFile,
    ));

    await _loadAndPlayCurrentFile();
  }

  /// Przewija do określonej pozycji
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Ustawia głośność (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clampedVolume);
    emit(state.copyWith(volume: clampedVolume));
  }

  /// Obsługuje zakończenie odtwarzania utworu
  void _onTrackCompleted() {
    if (state.canGoNext) {
      // Automatycznie przejdź do następnego utworu
      next();
    } else {
      // Ostatni utwór w playliście
      emit(state.copyWith(
        status: AudioPlayerStatus.stopped,
        currentPosition: Duration.zero,
      ));
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  // =============== OFFLINE CACHE METHODS ===============

  /// Ładuje statusy cache dla podanych plików
  Future<void> _loadCacheStatuses(List<SongFile> files) async {
    final Map<int, CacheStatus> newStatuses = {};
    
    for (final file in files) {
      final cachedFile = await _cacheService.getCachedFile(file.fileId);
      newStatuses[file.fileId] = cachedFile?.status ?? CacheStatus.notCached;
    }
    
    emit(state.copyWith(cacheStatuses: newStatuses));
  }

  /// Sprawdza dostępność offline dla wszystkich plików w playliście
  Future<void> checkOfflineAvailability() async {
    await _loadCacheStatuses(state.playlist);
  }

  /// Pobiera plik dla offline
  Future<void> downloadForOffline(SongFile file) async {
    try {
      // Aktualizuj status na downloading
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[file.fileId] = CacheStatus.downloading;
      emit(state.copyWith(cacheStatuses: newStatuses));

      // Zasubskrybuj progress
      _subscribeToDownloadProgress(file.fileId);

      // Pobierz URL do pliku
      final downloadUrl = await songRepository.getFileDownloadUrl(
        songId: songId,
        fileId: file.fileId,
      );

      // Rozpocznij pobieranie
      await _cacheService.downloadFile(file, downloadUrl);

      // Aktualizuj status na cached
      newStatuses[file.fileId] = CacheStatus.cached;
      emit(state.copyWith(cacheStatuses: newStatuses));

    } catch (e) {
      // Aktualizuj status na error
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[file.fileId] = CacheStatus.error;
      emit(state.copyWith(cacheStatuses: newStatuses));
      
      emit(state.copyWith(
        errorMessage: 'Błąd podczas pobierania pliku: $e',
      ));
    } finally {
      // Usuń subskrypcję progress
      _unsubscribeFromDownloadProgress(file.fileId);
    }
  }

  /// Odtwarza plik offline (tylko jeśli jest cache'owany)
  Future<void> playOfflineFile(SongFile file) async {
    final isAvailable = await _cacheService.isFileCached(file.fileId);
    if (!isAvailable) {
      emit(state.copyWith(
        errorMessage: 'Plik nie jest dostępny offline',
      ));
      return;
    }

    selectFile(file);
    await _loadAndPlayCurrentFile();
  }

  /// Usuwa plik z cache
  Future<void> removeFromCache(SongFile file) async {
    try {
      await _cacheService.deleteFile(file.fileId);
      
      // Aktualizuj status
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[file.fileId] = CacheStatus.notCached;
      emit(state.copyWith(cacheStatuses: newStatuses));
      
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Błąd podczas usuwania pliku z cache: $e',
      ));
    }
  }

  /// Anuluje pobieranie pliku
  Future<void> cancelDownload(int fileId) async {
    try {
      await _cacheService.cancelDownload(fileId);
      
      // Aktualizuj status
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[fileId] = CacheStatus.notCached;
      emit(state.copyWith(cacheStatuses: newStatuses));
      
      // Usuń progress
      final newProgresses = Map<int, DownloadProgress>.from(state.downloadProgresses);
      newProgresses.remove(fileId);
      emit(state.copyWith(downloadProgresses: newProgresses));
      
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Błąd podczas anulowania pobierania: $e',
      ));
    }
  }

  /// Subskrybuje progress pobierania dla danego pliku
  void _subscribeToDownloadProgress(int fileId) {
    final progressStream = _cacheService.downloadProgress(fileId);
    if (progressStream != null) {
      _downloadSubscriptions[fileId] = progressStream.listen((progress) {
        final newProgresses = Map<int, DownloadProgress>.from(state.downloadProgresses);
        newProgresses[fileId] = progress;
        emit(state.copyWith(downloadProgresses: newProgresses));
      });
    }
  }

  /// Usuwa subskrypcję progress pobierania
  void _unsubscribeFromDownloadProgress(int fileId) {
    _downloadSubscriptions[fileId]?.cancel();
    _downloadSubscriptions.remove(fileId);
    
    // Usuń progress z state
    final newProgresses = Map<int, DownloadProgress>.from(state.downloadProgresses);
    newProgresses.remove(fileId);
    emit(state.copyWith(downloadProgresses: newProgresses));
  }

  /// Pobiera statystyki cache
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }

  /// Czyści cały cache audio
  Future<void> clearAllCache() async {
    try {
      await _cacheService.clearCache();
      
      // Zresetuj wszystkie statusy
      final newStatuses = <int, CacheStatus>{};
      for (final file in state.playlist) {
        newStatuses[file.fileId] = CacheStatus.notCached;
      }
      
      emit(state.copyWith(
        cacheStatuses: newStatuses,
        downloadProgresses: const {},
      ));
      
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Błąd podczas czyszczenia cache: $e',
      ));
    }
  }

  // =============== SMART CACHING METHODS ===============

  /// Rozpoczyna automatyczne cache'owanie w tle podczas streamingu
  void _startBackgroundCaching(SongFile file, String downloadUrl) {
    // Fire-and-forget - nie czekamy na zakończenie
    _backgroundCacheFile(file, downloadUrl).catchError((error) {
      print('Background caching error for file ${file.fileId}: $error');
      // Opcjonalnie możemy zaktualizować status na error, ale nie przerywamy odtwarzania
    });
  }

  /// Automatyczne cache'owanie pliku w tle
  Future<void> _backgroundCacheFile(SongFile file, String downloadUrl) async {
    try {
      // Sprawdź czy plik już nie jest cache'owany lub w trakcie pobierania
      final existingFile = await _cacheService.getCachedFile(file.fileId);
      if (existingFile?.status == CacheStatus.cached || 
          existingFile?.status == CacheStatus.downloading) {
        return; // Skip if already cached or downloading
      }

      print('AudioPlayer: Starting background cache for file ${file.fileId}');
      
      // Aktualizuj status na downloading (ale dyskretnie, bez progress UI)
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[file.fileId] = CacheStatus.downloading;
      emit(state.copyWith(cacheStatuses: newStatuses));

      // Rozpocznij pobieranie w tle
      await _cacheService.downloadFile(file, downloadUrl);

      // Aktualizuj status na cached
      newStatuses[file.fileId] = CacheStatus.cached;
      emit(state.copyWith(cacheStatuses: newStatuses));

      print('AudioPlayer: Background cache completed for file ${file.fileId}');

    } catch (e) {
      // Aktualizuj status na error (dyskretnie)
      final newStatuses = Map<int, CacheStatus>.from(state.cacheStatuses);
      newStatuses[file.fileId] = CacheStatus.error;
      emit(state.copyWith(cacheStatuses: newStatuses));
      
      print('AudioPlayer: Background cache failed for file ${file.fileId}: $e');
      // Nie pokazujemy błędu użytkownikowi - streaming nadal działa
    }
  }

  /// Sprawdza i cache'uje następne pliki w playliście (predictive caching)
  Future<void> _preloadNextFiles() async {
    if (state.playlist.isEmpty || state.currentIndex >= state.playlist.length - 1) {
      return;
    }

    try {
      // Cache następny plik w playliście
      final nextIndex = state.currentIndex + 1;
      if (nextIndex < state.playlist.length) {
        final nextFile = state.playlist[nextIndex];
        final isAlreadyCached = await _cacheService.isFileCached(nextFile.fileId);
        
        if (!isAlreadyCached) {
          final downloadUrl = await songRepository.getFileDownloadUrl(
            songId: songId,
            fileId: nextFile.fileId,
          );
          
          print('AudioPlayer: Preloading next file ${nextFile.fileId}');
          _startBackgroundCaching(nextFile, downloadUrl);
        }
      }
    } catch (e) {
      print('AudioPlayer: Preload failed: $e');
      // Ignoruj błędy preload - nie są krytyczne
    }
  }

  @override
  Future<void> close() async {
    // Anuluj wszystkie subskrypcje download progress
    for (final subscription in _downloadSubscriptions.values) {
      await subscription.cancel();
    }
    _downloadSubscriptions.clear();
    
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}