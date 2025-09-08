import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class TrackPlayerCubit extends Cubit<TrackPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, int> _trackIdToPlayerIndex = {};
  final Map<int, AudioSource> _audioSources = {};
  final Dio _dio = Dio();
  int? _currentProjectId;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription<List<Track>>? _tracksSubscription;

  TrackPlayerCubit() : super(const TrackPlayerState()) {
    _listenToPlayerEvents();
  }

  void _listenToPlayerEvents() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final newStatus = _mapProcessingStateToPlayerUiStatus(playerState);
      emit(state.copyWith(playerUiStatus: newStatus));
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (!state.isSeeking) {
        emit(state.copyWith(currentPosition: position));
      }
    });

    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((
      bufferedPosition,
    ) {
      emit(state.copyWith(bufferedPosition: bufferedPosition));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(totalDuration: duration ?? Duration.zero));
    });
  }

  Future<void> loadTracksDirectly(
    List<Track> tracks,
    int initialTrackId,
    int projectId,
  ) async {
    _currentProjectId = projectId;

    final initialIndex = tracks.indexWhere((t) => t.id == initialTrackId);

    emit(
      state.copyWith(
        tracks: tracks,
        currentTrackIndex: initialIndex != -1 ? initialIndex : 0,
      ),
    );

    await _processTracks(tracks, initialTrackId, isInitialLoad: true);

    _startPreCaching();
  }

  Future<void> _processTracks(
    List<Track> tracks,
    int initialTrackId, {
    bool isInitialLoad = false,
  }) async {
    final List<AudioSource> playableSources = [];
    _trackIdToPlayerIndex.clear();

    for (final track in tracks) {
      final url = track.mainVersion?.file?.downloadUrl;
      if (url != null) {
        final audioSource = await _createCachingAudioSource(url, track.id);
        _trackIdToPlayerIndex[track.id] = playableSources.length;
        playableSources.add(audioSource);
      }
    }

    if (isInitialLoad || _didPlaylistChange(playableSources)) {
      if (playableSources.isNotEmpty) {
        await _audioPlayer.setAudioSources(playableSources);
      }
    }

    final initialIndex = tracks.indexWhere((t) => t.id == initialTrackId);

    emit(
      state.copyWith(
        tracks: tracks,
        currentTrackIndex: state.currentTrackIndex == 0 && initialIndex != -1
            ? initialIndex
            : state.currentTrackIndex,
      ),
    );

    if (isInitialLoad && initialIndex != -1) {
      selectTrack(initialIndex);
    }
  }

  bool _didPlaylistChange(List<AudioSource> newSources) {
    final currentSources = _audioPlayer.sequence;
    if (currentSources.length != newSources.length) {
      return true;
    }

    for (int i = 0; i < currentSources.length; i++) {
      final s1 = (currentSources[i] as LockCachingAudioSource).uri.toString();
      final s2 = (newSources[i] as LockCachingAudioSource).uri.toString();
      if (s1 != s2) {
        return true;
      }
    }
    return false;
  }

  void selectTrack(int index) {
    if (index < 0 || index >= state.tracks.length) {
      return;
    }

    emit(state.copyWith(currentTrackIndex: index));
  }

  Future<void> playSelectedTrack() async {
    final track = state.currentTrack;
    if (track == null) return;

    final playerIndex = _trackIdToPlayerIndex[track.id];

    if (playerIndex != null) {
      await _audioPlayer.seek(Duration.zero, index: playerIndex);
      await _audioPlayer.play();
    } else {
      await _audioPlayer.stop();
    }
  }

  Future<void> togglePlayPause() async {
    if (state.playerUiStatus == PlayerUiStatus.playing) {
      await _audioPlayer.pause();
    } else if (state.playerUiStatus == PlayerUiStatus.paused) {
      await _audioPlayer.play();
    } else {
      // Jeśli idle/completed - rozpocznij odtwarzanie wybranego utworu
      await playSelectedTrack();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void startSeeking() {
    emit(
      state.copyWith(
        isSeeking: true,
        seekPosition: state.currentPosition,
      ),
    );
  }

  void updateSeekPosition(double value) {
    if (!state.isSeeking) return;

    final newPosition = Duration(
      milliseconds: (value * state.totalDuration.inMilliseconds).round(),
    );

    emit(
      state.copyWith(
        seekPosition: newPosition,
      ),
    );
  }

  Future<void> endSeeking() async {
    if (!state.isSeeking || state.seekPosition == null) return;

    final targetPosition = state.seekPosition!;

    emit(
      state.copyWith(
        isSeeking: false,
        seekPosition: null,
        currentPosition: targetPosition,
      ),
    );

    await _audioPlayer.seek(targetPosition);
  }

  void seekToNext() {
    if (state.hasNext) {
      selectTrack(state.currentTrackIndex + 1);
      _audioPlayer.seekToNext();
    }
  }

  void seekToPrevious() {
    if (state.hasPrevious) {
      selectTrack(state.currentTrackIndex - 1);
      _audioPlayer.seekToPrevious();
    }
  }

  void setLoopMode(LoopMode mode) {
    _audioPlayer.setLoopMode(mode);
    emit(state.copyWith(loopMode: mode));
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

  Future<File> _getCacheFileForTrack(int trackId) async {
    final cacheDir = await getTemporaryDirectory();
    final projectCacheDir = Directory(
      '${cacheDir.path}/audio_cache/project_$_currentProjectId',
    );

    if (!await projectCacheDir.exists()) {
      await projectCacheDir.create(recursive: true);
    }

    return File('${projectCacheDir.path}/track_$trackId.cache');
  }

  Future<AudioSource> _createCachingAudioSource(String url, int trackId) async {
    final cacheFile = await _getCacheFileForTrack(trackId);

    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: cacheFile,
    );
  }

  Future<void> _downloadTrackToCache(String url, int trackId) async {
    final cacheFile = await _getCacheFileForTrack(trackId);

    // Sprawdź czy plik już istnieje
    if (await cacheFile.exists()) {
      return; // Już cache'owany
    }

    // Downloaduj plik używając Dio
    await _dio.download(url, cacheFile.path);
  }

  Future<void> _startPreCaching() async {
    emit(state.copyWith(isPreCaching: true));

    // Inicjalizuj cache status dla wszystkich tracks
    final initialCacheStatus = <int, CacheStatus>{};
    for (final track in state.tracks) {
      initialCacheStatus[track.id] = CacheStatus.notStarted;
    }

    emit(state.copyWith(tracksCacheStatus: initialCacheStatus));

    // Przetworz wszystkie tracks
    for (final track in state.tracks) {
      await _processTrackForCaching(track);
    }
  }

  Future<void> _processTrackForCaching(Track track) async {
    final trackId = track.id;
    final url = track.mainVersion?.file?.downloadUrl;

    if (url == null) {
      // Track nie ma pliku - ustaw status noFile
      final updatedStatus = Map<int, CacheStatus>.from(state.tracksCacheStatus);
      updatedStatus[trackId] = CacheStatus.noFile;
      _updateCacheProgress(updatedStatus);
      return;
    }

    try {
      // Update status na caching
      final updatedStatus = Map<int, CacheStatus>.from(state.tracksCacheStatus);
      updatedStatus[trackId] = CacheStatus.caching;
      emit(state.copyWith(tracksCacheStatus: updatedStatus));

      // Utwórz cache file path i downloaduj plik
      await _downloadTrackToCache(url, trackId);

      // Utwórz audio source (będzie używać już cache'owanego pliku)
      final audioSource = await _createCachingAudioSource(url, trackId);

      // Zapisz audio source
      _audioSources[trackId] = audioSource;

      // Update status na cached
      final finalStatus = Map<int, CacheStatus>.from(state.tracksCacheStatus);
      finalStatus[trackId] = CacheStatus.cached;
      _updateCacheProgress(finalStatus);
    } catch (e) {
      // Update status na error
      final errorStatus = Map<int, CacheStatus>.from(state.tracksCacheStatus);
      errorStatus[trackId] = CacheStatus.error;
      _updateCacheProgress(errorStatus);
    }
  }

  void _updateCacheProgress(Map<int, CacheStatus> statusMap) {
    final processedCount = statusMap.values
        .where(
          (s) =>
              s == CacheStatus.cached ||
              s == CacheStatus.noFile ||
              s == CacheStatus.error,
        )
        .length;

    final cachedCount = statusMap.values
        .where((s) => s == CacheStatus.cached)
        .length;

    emit(
      state.copyWith(
        tracksCacheStatus: statusMap,
        cachedTracksCount: cachedCount,
        isPreCaching: processedCount < state.tracks.length,
      ),
    );
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _tracksSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
