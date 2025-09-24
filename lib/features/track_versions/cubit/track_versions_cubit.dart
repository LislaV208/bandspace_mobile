import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/shared/models/version.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackVersionsCubit extends Cubit<TrackVersionsState> {
  final ProjectsRepository _repository;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int? _projectId;
  int? _trackId;
  StreamSubscription<List<Version>>? _versionsSubscription;

  // Audio player subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;

  TrackVersionsCubit({
    required ProjectsRepository repository,
  }) : _repository = repository,
       super(const TrackVersionsInitial()) {
    _listenToPlayerEvents();
  }

  void initialize({
    required int projectId,
    required int trackId,
  }) {
    _projectId = projectId;
    _trackId = trackId;
    loadVersions();
  }

  Future<void> loadVersions() async {
    if (_projectId == null || _trackId == null) {
      emit(const TrackVersionsError('Project ID or Track ID not initialized'));
      return;
    }

    emit(const TrackVersionsLoading());

    try {
      final response = await _repository.getTrackVersions(
        _projectId!,
        _trackId!,
      );

      final cached = response.cached;
      final stream = response.stream;

      // Jeśli mamy cache, pokaż dane z cache i oznacz jako refreshing
      if (cached != null) {
        final currentState = state;
        if (currentState is TrackVersionsWithData) {
          // Zachowaj pełny stan playera
          emit(
            TrackVersionsRefreshing(
              cached,
              currentVersion: currentState.currentVersion,
              playerUiStatus: currentState.playerUiStatus,
              currentPosition: currentState.currentPosition,
              bufferedPosition: currentState.bufferedPosition,
              totalDuration: currentState.totalDuration,
              isSeeking: currentState.isSeeking,
              seekPosition: currentState.seekPosition,
            ),
          );
        } else {
          // Pierwszne ładowanie z cache - wybierz najnowszą wersję bez odtwarzania
          emit(TrackVersionsRefreshing(cached));
          if (cached.isNotEmpty) {
            // Delay to allow state to settle, then select version
            Future.microtask(() => _selectVersionWithoutAutoplay(cached.first));
          }
        }
      } else {
        emit(const TrackVersionsLoading());
      }

      _versionsSubscription?.cancel();
      _versionsSubscription = stream.listen(
        (versions) {
          if (state is! TrackVersionsRefreshing) {
            emit(TrackVersionsLoaded(versions));
          } else {
            // Preserve player state when updating from cache
            final currentState = state as TrackVersionsRefreshing;
            emit(
              TrackVersionsLoaded(
                versions,
                currentVersion: currentState.currentVersion,
                playerUiStatus: currentState.playerUiStatus,
                currentPosition: currentState.currentPosition,
                bufferedPosition: currentState.bufferedPosition,
                totalDuration: currentState.totalDuration,
                isSeeking: currentState.isSeeking,
                seekPosition: currentState.seekPosition,
              ),
            );
          }

          // Sprawdź czy to pierwsze ładowanie (brak currentVersion)
          final currentState = state;
          final shouldAutoSelectVersion =
              versions.isNotEmpty &&
              (currentState is! TrackVersionsWithData ||
                  currentState.currentVersion == null);

          log(
            '[TrackVersionsCubit] Loaded ${versions.length} versions, shouldAutoSelect: $shouldAutoSelectVersion',
          );

          // Automatycznie wybierz najnowszą wersję (pierwszą w liście) przy pierwszym ładowaniu
          if (shouldAutoSelectVersion) {
            _selectVersionWithoutAutoplay(versions.first);
          }
        },
        onError: (error) {
          final currentState = state;
          if (currentState is TrackVersionsWithData) {
            // Jeśli mamy dane, zostaw je i pokaż tylko błąd
            log('[TrackVersionsCubit] Error refreshing versions: $error');
          } else {
            emit(TrackVersionsError(error.toString()));
          }
        },
      );
    } catch (error) {
      emit(TrackVersionsError(error.toString()));
    }
  }

  Future<void> refreshVersions() async {
    if (_projectId == null || _trackId == null) {
      emit(const TrackVersionsError('Project ID or Track ID not initialized'));
      return;
    }

    final currentState = state;
    if (currentState is TrackVersionsWithData) {
      emit(TrackVersionsRefreshing(currentState.versions));
    }

    try {
      await _repository.refreshTrackVersions(_projectId!, _trackId!);
      // Nowy stan będzie emitowany przez stream subscription
    } catch (error) {
      emit(TrackVersionsError(error.toString()));
    }
  }

  // Audio player event listeners
  void _listenToPlayerEvents() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final newStatus = _mapProcessingStateToPlayerUiStatus(playerState);
      _updatePlayerState(playerUiStatus: newStatus);
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      final currentState = state;
      if (currentState is TrackVersionsWithData && !currentState.isSeeking) {
        _updatePlayerState(currentPosition: position);
      }
    });

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((
      bufferedPosition,
    ) {
      _updatePlayerState(bufferedPosition: bufferedPosition);
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _updatePlayerState(totalDuration: duration);
      }
    });
  }

  PlayerUiStatus _mapProcessingStateToPlayerUiStatus(PlayerState playerState) {
    switch (playerState.processingState) {
      case ProcessingState.idle:
        return PlayerUiStatus.idle;
      case ProcessingState.loading:
        return PlayerUiStatus.loading;
      case ProcessingState.buffering:
        return PlayerUiStatus.loading;
      case ProcessingState.ready:
        return playerState.playing
            ? PlayerUiStatus.playing
            : PlayerUiStatus.paused;
      case ProcessingState.completed:
        return PlayerUiStatus.paused;
    }
  }

  void _updatePlayerState({
    Version? currentVersion,
    PlayerUiStatus? playerUiStatus,
    Duration? currentPosition,
    Duration? bufferedPosition,
    Duration? totalDuration,
    bool? isSeeking,
    Duration? seekPosition,
  }) {
    final currentState = state;
    if (currentState is TrackVersionsLoaded) {
      emit(
        currentState.copyWith(
          currentVersion: currentVersion != null ? Value(currentVersion) : null,
          playerUiStatus: playerUiStatus,
          currentPosition: currentPosition,
          bufferedPosition: bufferedPosition,
          totalDuration: totalDuration,
          isSeeking: isSeeking,
          seekPosition: seekPosition != null ? Value(seekPosition) : null,
        ),
      );
    } else if (currentState is TrackVersionsRefreshing) {
      // Również aktualizuj stan podczas refreshing
      emit(
        TrackVersionsRefreshing(
          currentState.versions,
          currentVersion: currentVersion ?? currentState.currentVersion,
          playerUiStatus: playerUiStatus ?? currentState.playerUiStatus,
          currentPosition: currentPosition ?? currentState.currentPosition,
          bufferedPosition: bufferedPosition ?? currentState.bufferedPosition,
          totalDuration: totalDuration ?? currentState.totalDuration,
          isSeeking: isSeeking ?? currentState.isSeeking,
          seekPosition: seekPosition ?? currentState.seekPosition,
        ),
      );
    }
  }

  // Audio player controls
  Future<void> selectVersion(Version version) async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData) return;

    // Jeśli wybieramy aktualnie odtwarzaną wersję, przełącz play/pause
    if (currentState.currentVersion?.id == version.id) {
      log(
        '[TrackVersionsCubit] Toggling play/pause for current version: ${version.id}',
      );
      await togglePlayPause();
    } else {
      // Wybieramy nową wersję - odtwórz automatycznie
      await _selectVersionWithAutoplay(version);
    }
  }

  /// Wybiera wersję bez automatycznego odtwarzania (używane przy pierwszym ładowaniu)
  void _selectVersionWithoutAutoplay(Version version) {
    final url = version.file?.downloadUrl;
    if (url == null) {
      log(
        '[TrackVersionsCubit] Cannot select version ${version.id} - no downloadUrl in file: ${version.file?.filename}',
      );
      return;
    }

    log(
      '[TrackVersionsCubit] Selecting version without autoplay: ${version.id} (${version.file?.filename})',
    );

    _updatePlayerState(
      currentVersion: version,
      playerUiStatus: PlayerUiStatus.idle,
      currentPosition: Duration.zero,
      totalDuration: Duration.zero,
    );

    // Preload audio source ale nie odtwarzaj
    _preloadAudioSource(version);
  }

  /// Wybiera wersję z automatycznym odtwarzaniem (używane przy wyborze z listy)
  Future<void> _selectVersionWithAutoplay(Version version) async {
    final url = version.file?.downloadUrl;
    if (url == null) {
      log(
        '[TrackVersionsCubit] Cannot play version ${version.id} - no downloadUrl in file: ${version.file?.filename}',
      );
      return;
    }

    log(
      '[TrackVersionsCubit] Selecting version with autoplay: ${version.id} (${version.file?.filename})',
    );

    try {
      _updatePlayerState(
        currentVersion: version,
        playerUiStatus: PlayerUiStatus.loading,
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
      );

      final audioSource = await _createCachingAudioSource(url, version.id);
      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play(); // Automatycznie odtwórz
    } catch (e) {
      log('[TrackVersionsCubit] Error playing version ${version.id}: $e');
      _updatePlayerState(playerUiStatus: PlayerUiStatus.error);
    }
  }

  /// Preload audio source w tle bez odtwarzania
  void _preloadAudioSource(Version version) async {
    final url = version.file?.downloadUrl;
    if (url == null) {
      log(
        '[TrackVersionsCubit] Cannot preload version ${version.id} - no downloadUrl in file: ${version.file?.filename}',
      );
      return;
    }

    log(
      '[TrackVersionsCubit] Preloading audio source for version: ${version.id} (${version.file?.filename})',
    );

    try {
      final audioSource = await _createCachingAudioSource(url, version.id);
      await _audioPlayer.setAudioSource(audioSource);
      // Nie wywołujemy play() - tylko preload
    } catch (e) {
      log('[TrackVersionsCubit] Error preloading version ${version.id}: $e');
      // Ignoruj błędy preload - użytkownik może i tak nie odtworzyć tej wersji
    }
  }

  Future<void> togglePlayPause() async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData) return;

    switch (currentState.playerUiStatus) {
      case PlayerUiStatus.playing:
        await _audioPlayer.pause();
        break;
      case PlayerUiStatus.paused:
        await _audioPlayer.play();
        break;
      case PlayerUiStatus.idle:
      case PlayerUiStatus.completed:
        if (currentState.currentVersion != null) {
          await selectVersion(currentState.currentVersion!);
          await _audioPlayer.play();
        }
        break;
      case PlayerUiStatus.loading:
      case PlayerUiStatus.error:
        break;
    }
  }

  /// Zatrzymuje odtwarzanie (używane przy nawigacji do innych ekranów)
  Future<void> pausePlayback() async {
    final currentState = state;
    if (currentState is TrackVersionsWithData &&
        currentState.playerUiStatus == PlayerUiStatus.playing) {
      log('[TrackVersionsCubit] Pausing playback due to navigation');
      await _audioPlayer.pause();
    }
  }

  Future<void> playNext() async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData || !currentState.hasNext) return;

    final currentVersion = currentState.currentVersion;
    if (currentVersion == null) return;

    final currentIndex = currentState.versions.indexOf(currentVersion);
    if (currentIndex < currentState.versions.length - 1) {
      final nextVersion = currentState.versions[currentIndex + 1];
      await _selectVersionWithAutoplay(nextVersion);
    }
  }

  Future<void> playPrevious() async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData || !currentState.hasPrevious) {
      return;
    }

    final currentVersion = currentState.currentVersion;
    if (currentVersion == null) return;

    final currentIndex = currentState.versions.indexOf(currentVersion);
    if (currentIndex > 0) {
      final prevVersion = currentState.versions[currentIndex - 1];
      await _selectVersionWithAutoplay(prevVersion);
    }
  }

  void startSeeking() {
    final currentState = state;
    if (currentState is TrackVersionsWithData) {
      _updatePlayerState(
        isSeeking: true,
        seekPosition: currentState.currentPosition,
      );
    }
  }

  void updateSeekPosition(double value) {
    final currentState = state;
    if (currentState is! TrackVersionsWithData || !currentState.isSeeking) {
      return;
    }

    final newPosition = Duration(
      milliseconds: (value * currentState.totalDuration.inMilliseconds).round(),
    );

    _updatePlayerState(seekPosition: newPosition);
  }

  Future<void> endSeeking() async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData ||
        !currentState.isSeeking ||
        currentState.seekPosition == null) {
      return;
    }

    final targetPosition = currentState.seekPosition!;

    _updatePlayerState(
      isSeeking: false,
      seekPosition: null,
      currentPosition: targetPosition,
    );

    await _audioPlayer.seek(targetPosition);
  }

  Future<void> seek(double value) async {
    final currentState = state;
    if (currentState is! TrackVersionsWithData) return;

    await _audioPlayer.seek(
      Duration(
        milliseconds: (value * currentState.totalDuration.inMilliseconds)
            .round(),
      ),
    );
  }

  // Cache management
  Future<AudioSource> _createCachingAudioSource(
    String url,
    int versionId,
  ) async {
    final cacheDir = await getTemporaryDirectory();
    final projectCacheDir = Directory(
      '${cacheDir.path}/audio_cache/project_$_projectId/track_$_trackId',
    );

    if (!await projectCacheDir.exists()) {
      await projectCacheDir.create(recursive: true);
    }

    final cacheFile = File('${projectCacheDir.path}/version_$versionId.cache');

    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: cacheFile,
    );
  }

  @override
  Future<void> close() {
    _versionsSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
