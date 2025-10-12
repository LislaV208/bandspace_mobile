import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_player_service.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_pre_caching_orchestrator.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_source_factory.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackPlayerCubit extends Cubit<TrackPlayerState> {
  final AudioPlayerService _playerService;
  final AudioSourceFactory _sourceFactory;
  final AudioPreCachingOrchestrator _preCachingOrchestrator;
  final Map<int, int> _trackIdToPlayerIndex = {};

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _cacheProgressSubscription;
  StreamSubscription<List<Track>>? _tracksSubscription;

  TrackPlayerCubit({
    required AudioPlayerService playerService,
    required AudioSourceFactory sourceFactory,
    required AudioPreCachingOrchestrator preCachingOrchestrator,
  }) : _playerService = playerService,
       _sourceFactory = sourceFactory,
       _preCachingOrchestrator = preCachingOrchestrator,
       super(const TrackPlayerState()) {
    _listenToPlayerEvents();
    _listenToCacheProgress();
  }

  void _listenToPlayerEvents() {
    _playerStateSubscription = _playerService.playerStateStream.listen((
      playerState,
    ) {
      final newStatus = _mapProcessingStateToPlayerUiStatus(playerState);
      emit(state.copyWith(playerUiStatus: newStatus));
    });

    _positionSubscription = _playerService.positionStream.listen((position) {
      if (!state.isSeeking) {
        emit(state.copyWith(currentPosition: position));
      }
    });

    _bufferedPositionSubscription = _playerService.bufferedPositionStream
        .listen((
          bufferedPosition,
        ) {
          emit(state.copyWith(bufferedPosition: bufferedPosition));
        });

    _durationSubscription = _playerService.durationStream.listen((duration) {
      emit(state.copyWith(totalDuration: duration ?? Duration.zero));
    });
  }

  void _listenToCacheProgress() {
    _cacheProgressSubscription = _preCachingOrchestrator.progressStream.listen(
      (progress) {
        emit(
          state.copyWith(
            tracksCacheStatus: progress.tracksCacheStatus,
            cachedTracksCount: progress.cachedCount,
            isPreCaching: !progress.isComplete,
          ),
        );
      },
    );
  }

  Future<void> initialize(
    List<Track> tracks,
    int initialTrackId,
    int projectId,
  ) async {
    final initialIndex = tracks.indexWhere((t) => t.id == initialTrackId);

    emit(
      state.copyWith(
        tracks: tracks,
        currentTrackIndex: initialIndex != -1 ? initialIndex : 0,
        currentProjectId: projectId,
      ),
    );

    await _processTracks(tracks, initialTrackId);

    _preCachingOrchestrator.preCacheTracks(state.tracks);
  }

  Future<void> _processTracks(
    List<Track> tracks,
    int initialTrackId,
  ) async {
    final List<AudioSource> playableSources = [];
    _trackIdToPlayerIndex.clear();

    for (final track in tracks) {
      final url = track.mainVersion?.file?.downloadUrl;

      if (url == null) {
        log(
          'Track ${track.id} has no download URL, skipping from playlist',
          name: 'TrackPlayerCubit',
        );
        continue;
      }

      try {
        final audioSource = await _sourceFactory.createAudioSource(
          url,
          track.id,
        );
        _trackIdToPlayerIndex[track.id] = playableSources.length;
        playableSources.add(audioSource);
      } catch (e) {
        log(
          'Failed to create audio source for track ${track.id}: $e. Skipping.',
          name: 'TrackPlayerCubit',
        );
        // Graceful degradation: skip this track, continue with others
      }
    }

    if (playableSources.isNotEmpty) {
      await _playerService.setAudioSources(playableSources);
    } else {
      log(
        'No playable tracks available in playlist',
        name: 'TrackPlayerCubit',
      );
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

    if (initialIndex != -1) {
      selectTrack(initialIndex);
    }
  }

  // bool _didPlaylistChange(List<AudioSource> newSources) {
  //   final currentSources = _playerService.sequence;
  //   if (currentSources.length != newSources.length) {
  //     return true;
  //   }

  //   for (int i = 0; i < currentSources.length; i++) {
  //     final s1 = (currentSources[i] as LockCachingAudioSource).uri.toString();
  //     final s2 = (newSources[i] as LockCachingAudioSource).uri.toString();
  //     if (s1 != s2) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

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
      await _playerService.seek(Duration.zero, index: playerIndex);
      await _playerService.play();
    } else {
      await _playerService.stop();
    }
  }

  Future<void> togglePlayPause() async {
    if (state.playerUiStatus == PlayerUiStatus.playing) {
      await _playerService.pause();
    } else if (state.playerUiStatus == PlayerUiStatus.paused) {
      await _playerService.play();
    } else {
      // Jeśli idle/completed - rozpocznij odtwarzanie wybranego utworu
      await playSelectedTrack();
    }
  }

  /// Zatrzymuje odtwarzanie (używane przy nawigacji do innych ekranów)
  Future<void> pausePlayback() async {
    if (state.playerUiStatus == PlayerUiStatus.playing) {
      await _playerService.pause();
    }
  }

  void seek(Duration position) {
    _playerService.seek(position);
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

    await _playerService.seek(targetPosition);
  }

  void seekToNext() {
    if (state.hasNext) {
      selectTrack(state.currentTrackIndex + 1);
      _playerService.seekToNext();
    }
  }

  void seekToPrevious() {
    if (state.hasPrevious) {
      selectTrack(state.currentTrackIndex - 1);
      _playerService.seekToPrevious();
    }
  }

  void setLoopMode(LoopMode mode) {
    _playerService.setLoopMode(mode);
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

  /// Aktualizuje konkretną ścieżkę w liście tracks
  void updateTrack(Track updatedTrack) {
    final currentTracks = List<Track>.from(state.tracks);
    final trackIndex = currentTracks.indexWhere(
      (track) => track.id == updatedTrack.id,
    );

    if (trackIndex != -1) {
      currentTracks[trackIndex] = updatedTrack;
      emit(state.copyWith(tracks: currentTracks));
    }
  }

  /// Aktualizuje główną wersję dla danego track-u
  void updateTrackMainVersion(int trackId, Version newMainVersion) {
    final currentTracks = List<Track>.from(state.tracks);
    final trackIndex = currentTracks.indexWhere(
      (track) => track.id == trackId,
    );

    if (trackIndex != -1) {
      final currentTrack = currentTracks[trackIndex];

      // Sprawdź czy wersja rzeczywiście się zmieniła
      if (currentTrack.mainVersion?.id == newMainVersion.id) {
        log(
          'Version unchanged for track $trackId, skipping update',
          name: 'TrackPlayerCubit',
        );
        return;
      }

      final updatedTrack = Track(
        id: currentTrack.id,
        title: currentTrack.title,
        createdAt: currentTrack.createdAt,
        updatedAt: currentTrack.updatedAt,
        mainVersion: newMainVersion,
        createdBy: currentTrack.createdBy,
      );

      currentTracks[trackIndex] = updatedTrack;
      emit(state.copyWith(tracks: currentTracks));

      log(
        'Updated main version for track $trackId to version ${newMainVersion.id}',
        name: 'TrackPlayerCubit',
      );

      // Jeśli to obecnie odtwarzany track, przebuduj audio sources
      if (state.currentTrack?.id == trackId) {
        _rebuildAudioSourcesForCurrentTrack(updatedTrack);
      }
    }
  }

  Future<void> _rebuildAudioSourcesForCurrentTrack(Track updatedTrack) async {
    final url = updatedTrack.mainVersion?.file?.downloadUrl;
    if (url == null) {
      log(
        'Cannot rebuild audio sources - no download URL for track ${updatedTrack.id}',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final playerIndex = _trackIdToPlayerIndex[updatedTrack.id];
    if (playerIndex == null) {
      log(
        'Track ${updatedTrack.id} not in player index, cannot rebuild',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    try {
      // Utwórz nowy audio source dla zaktualizowanego track-u
      final audioSource = await _sourceFactory.createAudioSource(
        url,
        updatedTrack.id,
      );

      // Zastąp audio source w player-ze
      final currentSequence = _playerService.sequence;
      final sources = List<AudioSource>.from(currentSequence);
      sources[playerIndex] = audioSource;

      await _playerService.setAudioSources(sources);

      log(
        'Rebuilt audio source for track ${updatedTrack.id} with new version',
        name: 'TrackPlayerCubit',
      );
    } catch (e) {
      log(
        'Failed to rebuild audio sources for track ${updatedTrack.id}: $e',
        name: 'TrackPlayerCubit',
      );
      // Graceful degradation: stary source pozostaje aktywny
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _cacheProgressSubscription?.cancel();
    _tracksSubscription?.cancel();
    _preCachingOrchestrator.dispose();
    _playerService.dispose();
    return super.close();
  }
}
