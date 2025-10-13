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
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription<List<Track>>? _tracksSubscription;

  TrackPlayerCubit({
    required AudioPlayerService playerService,
    required AudioSourceFactory sourceFactory,
    required AudioPreCachingOrchestrator preCachingOrchestrator,
  }) : _playerService = playerService,
       _sourceFactory = sourceFactory,
       _preCachingOrchestrator = preCachingOrchestrator,
       super(const TrackPlayerState());

  void _listenToPlayerEvents() {
    log(
      '_listenToPlayerEvents: Setting up player event listeners',
      name: 'TrackPlayerCubit',
    );

    _currentIndexSubscription = _playerService.currentIndexStream.listen((
      index,
    ) {
      if (index == null) {
        return;
      }

      final trackId = _trackIdToPlayerIndex.entries
          .firstWhere(
            (entry) => entry.value == index,
          )
          .key;

      final trackIndex = state.tracks.indexWhere((t) => t.id == trackId);
      emit(state.copyWith(currentTrackIndex: trackIndex));
    });

    _playerStateSubscription = _playerService.playerStateStream.listen((
      playerState,
    ) {
      log('playerState: $playerState', name: 'TrackPlayerCubit');
      final newStatus = _getPlayerUiStatusFromPlayerState(playerState);
      log(
        '_listenToPlayerEvents: Player state changed - processingState=${playerState.processingState}, playing=${playerState.playing}, newStatus=$newStatus',
        name: 'TrackPlayerCubit',
      );
      emit(state.copyWith(playerUiStatus: newStatus));
    });

    _positionSubscription = _playerService.positionStream.listen((position) {
      if (!state.isSeeking) {
        emit(state.copyWith(currentPosition: position));
      }
    });

    _bufferedPositionSubscription = _playerService.bufferedPositionStream.listen((
      bufferedPosition,
    ) {
      log(
        '_listenToPlayerEvents: Buffered position updated - bufferedPosition=$bufferedPosition',
        name: 'TrackPlayerCubit',
      );
      emit(state.copyWith(bufferedPosition: bufferedPosition));
    });

    _durationSubscription = _playerService.durationStream.listen((duration) {
      log(
        '_listenToPlayerEvents: Duration updated - duration=$duration',
        name: 'TrackPlayerCubit',
      );
      emit(state.copyWith(totalDuration: duration ?? Duration.zero));
    });
  }

  void _listenToCacheProgress() {
    log(
      '_listenToCacheProgress: Setting up cache progress listener',
      name: 'TrackPlayerCubit',
    );

    _cacheProgressSubscription = _preCachingOrchestrator.progressStream.listen(
      (progress) {
        log(
          '_listenToCacheProgress: Cache progress updated - cachedCount=${progress.cachedCount}, isComplete=${progress.isComplete}',
          name: 'TrackPlayerCubit',
        );
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
    Track initialTrack,
    int projectId,
  ) async {
    log(
      'initialize: Starting initialization - tracksCount=${tracks.length}, initialTrackId=$initialTrack, projectId=$projectId',
      name: 'TrackPlayerCubit',
    );

    final initialIndex = tracks.indexWhere((t) => t.id == initialTrack.id);

    log(
      'initialize: Found initial track index=$initialIndex for track=$initialTrack',
      name: 'TrackPlayerCubit',
    );

    emit(
      state.copyWith(
        tracks: tracks,
        currentTrackIndex: initialIndex != -1 ? initialIndex : 0,
        currentProjectId: projectId,
      ),
    );
    await _processTracks(tracks);

    log(
      'initialize: Starting pre-caching for ${state.tracks.length} tracks',
      name: 'TrackPlayerCubit',
    );
    _preCachingOrchestrator.preCacheTracks(state.tracks);

    await _playerService.seek(
      Duration.zero,
      index: _trackIdToPlayerIndex[initialTrack.id],
    );

    _listenToPlayerEvents();
    _listenToCacheProgress();

    log('initialize: Initialization complete', name: 'TrackPlayerCubit');
  }

  Future<void> _processTracks(List<Track> tracks) async {
    log(
      '_processTracks: Processing ${tracks.length} tracks',
      name: 'TrackPlayerCubit',
    );

    final List<AudioSource> playableSources = [];
    _trackIdToPlayerIndex.clear();

    for (final track in tracks) {
      final url = track.mainVersion?.file?.downloadUrl;

      if (url == null) {
        log(
          '_processTracks: Track ${track.id} (${track.title}) has no download URL, skipping from playlist',
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
        log(
          '_processTracks: Successfully created audio source for track ${track.id} at index ${playableSources.length - 1}',
          name: 'TrackPlayerCubit',
        );
      } catch (e) {
        log(
          '_processTracks: Failed to create audio source for track ${track.id}: $e. Skipping.',
          name: 'TrackPlayerCubit',
        );
      }
    }

    log(
      '_processTracks: Created ${playableSources.length} playable sources out of ${tracks.length} tracks',
      name: 'TrackPlayerCubit',
    );

    if (playableSources.isNotEmpty) {
      await _playerService.setAudioSources(playableSources);
      log(
        '_processTracks: Set audio sources in player service',
        name: 'TrackPlayerCubit',
      );
    } else {
      log(
        '_processTracks: No playable tracks available in playlist',
        name: 'TrackPlayerCubit',
      );
    }

    log('_processTracks: Processing complete', name: 'TrackPlayerCubit');
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

  void _selectTrack(int index) {
    log(
      '_selectTrack: Selecting track at index=$index, tracksLength=${state.tracks.length}, currentStatus=${state.playerUiStatus}',
      name: 'TrackPlayerCubit',
    );

    if (index < 0 || index >= state.tracks.length) {
      log(
        '_selectTrack: Invalid index=$index, must be between 0 and ${state.tracks.length - 1}',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    if (index == state.currentTrackIndex) {
      log(
        '_selectTrack: Already selected track at index=$index',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final track = state.tracks[index];
    log(
      '_selectTrack: Selected track ${track.id} (${track.title}) at index $index',
      name: 'TrackPlayerCubit',
    );

    emit(state.copyWith(currentTrackIndex: index));

    log('_selectTrack: Complete', name: 'TrackPlayerCubit');
  }

  Future<void> onTracklistItemSelected(int index) async {
    log(
      'onTracklistItemSelected: Selected track at index=$index',
      name: 'TrackPlayerCubit',
    );
    if (index == state.currentTrackIndex) {
      await togglePlayPause();
    } else {
      _playTrackOfIndex(index);
    }
  }

  Future<void> _playTrackOfIndex(int index) async {
    log(
      '_playTrackOfIndex: Attempting to play track at index=$index, tracksLength=${state.tracks.length}',
      name: 'TrackPlayerCubit',
    );

    if (index < 0 || index >= state.tracks.length) {
      log(
        '_playTrackOfIndex: Invalid index=$index, must be between 0 and ${state.tracks.length - 1}',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final track = state.tracks[index];
    final playerIndex = _trackIdToPlayerIndex[track.id];

    log(
      '_playTrackOfIndex: Track ${track.id} (${track.title}), playerIndex=$playerIndex, currentTrackIndex=${state.currentTrackIndex}',
      name: 'TrackPlayerCubit',
    );

    if (playerIndex != null) {
      if (playerIndex != state.currentTrackIndex) {
        log(
          '_playTrackOfIndex: Seeking to playerIndex=$playerIndex',
          name: 'TrackPlayerCubit',
        );
        await _playerService.seek(Duration.zero, index: playerIndex);
      }
      log('_playTrackOfIndex: Starting playback', name: 'TrackPlayerCubit');
      await _playerService.play();
    } else {
      log(
        '_playTrackOfIndex: Track ${track.id} not found in player index map, cannot play',
        name: 'TrackPlayerCubit',
      );
    }

    log('_playTrackOfIndex: Complete', name: 'TrackPlayerCubit');
  }

  Future<void> togglePlayPause() async {
    log(
      'togglePlayPause: Current status=${state.playerUiStatus}',
      name: 'TrackPlayerCubit',
    );

    if (state.playerUiStatus == PlayerUiStatus.playing) {
      log('togglePlayPause: Pausing playback', name: 'TrackPlayerCubit');
      await _playerService.pause();
    } else if (state.playerUiStatus == PlayerUiStatus.paused) {
      log('togglePlayPause: Resuming playback', name: 'TrackPlayerCubit');
      await _playerService.play();
    } else {
      log(
        'togglePlayPause: Player in unexpected status ${state.playerUiStatus}, no action taken',
        name: 'TrackPlayerCubit',
      );
    }

    log('togglePlayPause: Complete', name: 'TrackPlayerCubit');
  }

  /// Zatrzymuje odtwarzanie (używane przy nawigacji do innych ekranów)
  Future<void> pausePlayback() async {
    log(
      'pausePlayback: Current status=${state.playerUiStatus}',
      name: 'TrackPlayerCubit',
    );

    if (state.playerUiStatus == PlayerUiStatus.playing) {
      log('pausePlayback: Pausing playback', name: 'TrackPlayerCubit');
      await _playerService.pause();
    } else {
      log(
        'pausePlayback: Player not playing, no action needed',
        name: 'TrackPlayerCubit',
      );
    }

    log('pausePlayback: Complete', name: 'TrackPlayerCubit');
  }

  void seek(Duration position) {
    log(
      'seek: Seeking to position=$position (${position.inSeconds}s)',
      name: 'TrackPlayerCubit',
    );
    _playerService.seek(position);
  }

  void startSeeking() {
    log(
      'startSeeking: Starting seek from position=${state.currentPosition}',
      name: 'TrackPlayerCubit',
    );

    emit(
      state.copyWith(
        isSeeking: true,
        seekPosition: state.currentPosition,
      ),
    );

    log('startSeeking: Seek mode enabled', name: 'TrackPlayerCubit');
  }

  void updateSeekPosition(double value) {
    if (!state.isSeeking) {
      log(
        'updateSeekPosition: Not in seeking mode, ignoring update',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final newPosition = Duration(
      milliseconds: (value * state.totalDuration.inMilliseconds).round(),
    );

    log(
      'updateSeekPosition: value=$value, newPosition=$newPosition (${newPosition.inSeconds}s/${state.totalDuration.inSeconds}s)',
      name: 'TrackPlayerCubit',
    );

    emit(
      state.copyWith(
        seekPosition: newPosition,
      ),
    );
  }

  Future<void> endSeeking() async {
    log(
      'endSeeking: isSeeking=${state.isSeeking}, seekPosition=${state.seekPosition}',
      name: 'TrackPlayerCubit',
    );

    if (!state.isSeeking || state.seekPosition == null) {
      log(
        'endSeeking: Not in seeking mode or no seek position, ignoring',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final targetPosition = state.seekPosition!;
    log(
      'endSeeking: Finalizing seek to position=$targetPosition (${targetPosition.inSeconds}s)',
      name: 'TrackPlayerCubit',
    );

    emit(
      state.copyWith(
        isSeeking: false,
        seekPosition: null,
        currentPosition: targetPosition,
      ),
    );

    await _playerService.seek(targetPosition);

    log('endSeeking: Seek complete', name: 'TrackPlayerCubit');
  }

  void seekToNext() {
    log(
      'seekToNext: currentIndex=${state.currentTrackIndex}, hasNext=${state.hasNext}',
      name: 'TrackPlayerCubit',
    );

    if (state.hasNext) {
      final nextIndex = state.currentTrackIndex + 1;
      log(
        'seekToNext: Moving to next track at index=$nextIndex',
        name: 'TrackPlayerCubit',
      );
      _selectTrack(nextIndex);
      _playerService.seekToNext();
    } else {
      log(
        'seekToNext: No next track available',
        name: 'TrackPlayerCubit',
      );
    }

    log('seekToNext: Complete', name: 'TrackPlayerCubit');
  }

  void seekToPrevious() {
    log(
      'seekToPrevious: currentIndex=${state.currentTrackIndex}, hasPrevious=${state.hasPrevious}',
      name: 'TrackPlayerCubit',
    );

    if (state.hasPrevious) {
      final prevIndex = state.currentTrackIndex - 1;
      log(
        'seekToPrevious: Moving to previous track at index=$prevIndex',
        name: 'TrackPlayerCubit',
      );
      _selectTrack(prevIndex);
      _playerService.seekToPrevious();
    } else {
      log(
        'seekToPrevious: No previous track available',
        name: 'TrackPlayerCubit',
      );
    }

    log('seekToPrevious: Complete', name: 'TrackPlayerCubit');
  }

  void setLoopMode(LoopMode mode) {
    log(
      'setLoopMode: Setting loop mode from ${state.loopMode} to $mode',
      name: 'TrackPlayerCubit',
    );

    _playerService.setLoopMode(mode);
    emit(state.copyWith(loopMode: mode));

    log('setLoopMode: Loop mode updated', name: 'TrackPlayerCubit');
  }

  PlayerUiStatus _getPlayerUiStatusFromPlayerState(
    PlayerState playerState,
  ) {
    final processingState = playerState.processingState;
    final playing = playerState.playing;

    PlayerUiStatus result;
    if (processingState == ProcessingState.buffering ||
        processingState == ProcessingState.ready) {
      result = playing ? PlayerUiStatus.playing : PlayerUiStatus.paused;
    } else {
      result = PlayerUiStatus.paused;
    }

    log(
      '_getPlayerUiStatusFromPlayerState: processingState=$processingState, playing=$playing -> $result',
      name: 'TrackPlayerCubit',
    );

    return result;
  }

  /// Aktualizuje konkretną ścieżkę w liście tracks
  void updateTrack(Track updatedTrack) {
    log(
      'updateTrack: Updating track ${updatedTrack.id} (${updatedTrack.title})',
      name: 'TrackPlayerCubit',
    );

    final currentTracks = List<Track>.from(state.tracks);
    final trackIndex = currentTracks.indexWhere(
      (track) => track.id == updatedTrack.id,
    );

    if (trackIndex != -1) {
      log(
        'updateTrack: Found track at index=$trackIndex, updating',
        name: 'TrackPlayerCubit',
      );
      currentTracks[trackIndex] = updatedTrack;
      emit(state.copyWith(tracks: currentTracks));
      log('updateTrack: Track updated successfully', name: 'TrackPlayerCubit');
    } else {
      log(
        'updateTrack: Track ${updatedTrack.id} not found in playlist',
        name: 'TrackPlayerCubit',
      );
    }
  }

  /// Aktualizuje główną wersję dla danego track-u
  void updateTrackMainVersion(int trackId, Version newMainVersion) {
    log(
      'updateTrackMainVersion: Updating main version for track $trackId to version ${newMainVersion.id}',
      name: 'TrackPlayerCubit',
    );

    final currentTracks = List<Track>.from(state.tracks);
    final trackIndex = currentTracks.indexWhere(
      (track) => track.id == trackId,
    );

    if (trackIndex == -1) {
      log(
        'updateTrackMainVersion: Track $trackId not found in playlist',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final currentTrack = currentTracks[trackIndex];
    log(
      'updateTrackMainVersion: Found track at index=$trackIndex, currentVersion=${currentTrack.mainVersion?.id}',
      name: 'TrackPlayerCubit',
    );

    // Sprawdź czy wersja rzeczywiście się zmieniła
    if (currentTrack.mainVersion?.id == newMainVersion.id) {
      log(
        'updateTrackMainVersion: Version unchanged for track $trackId, skipping update',
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
      'updateTrackMainVersion: Updated main version for track $trackId to version ${newMainVersion.id}',
      name: 'TrackPlayerCubit',
    );

    // Jeśli to obecnie odtwarzany track, przebuduj audio sources
    if (state.currentTrack?.id == trackId) {
      log(
        'updateTrackMainVersion: This is the current track, rebuilding audio sources',
        name: 'TrackPlayerCubit',
      );
      _rebuildAudioSourcesForCurrentTrack(updatedTrack);
    }
  }

  Future<void> _rebuildAudioSourcesForCurrentTrack(Track updatedTrack) async {
    log(
      '_rebuildAudioSourcesForCurrentTrack: Starting rebuild for track ${updatedTrack.id}',
      name: 'TrackPlayerCubit',
    );

    final url = updatedTrack.mainVersion?.file?.downloadUrl;
    if (url == null) {
      log(
        '_rebuildAudioSourcesForCurrentTrack: Cannot rebuild - no download URL for track ${updatedTrack.id}',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    final playerIndex = _trackIdToPlayerIndex[updatedTrack.id];
    if (playerIndex == null) {
      log(
        '_rebuildAudioSourcesForCurrentTrack: Track ${updatedTrack.id} not in player index map, cannot rebuild',
        name: 'TrackPlayerCubit',
      );
      return;
    }

    log(
      '_rebuildAudioSourcesForCurrentTrack: Track ${updatedTrack.id} at playerIndex=$playerIndex, creating new audio source from url=$url',
      name: 'TrackPlayerCubit',
    );

    try {
      // Utwórz nowy audio source dla zaktualizowanego track-u
      final audioSource = await _sourceFactory.createAudioSource(
        url,
        updatedTrack.id,
      );

      log(
        '_rebuildAudioSourcesForCurrentTrack: Audio source created, updating player sequence',
        name: 'TrackPlayerCubit',
      );

      // Zastąp audio source w player-ze
      final currentSequence = _playerService.sequence;
      final sources = List<AudioSource>.from(currentSequence);
      sources[playerIndex] = audioSource;

      await _playerService.setAudioSources(sources);

      log(
        '_rebuildAudioSourcesForCurrentTrack: Successfully rebuilt audio source for track ${updatedTrack.id}',
        name: 'TrackPlayerCubit',
      );
    } catch (e) {
      log(
        '_rebuildAudioSourcesForCurrentTrack: Failed to rebuild audio sources for track ${updatedTrack.id}: $e',
        name: 'TrackPlayerCubit',
      );
      // Graceful degradation: stary source pozostaje aktywny
    }
  }

  @override
  Future<void> close() {
    log(
      'close: Closing TrackPlayerCubit and cleaning up resources',
      name: 'TrackPlayerCubit',
    );

    log('close: Cancelling subscriptions', name: 'TrackPlayerCubit');
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _cacheProgressSubscription?.cancel();
    _tracksSubscription?.cancel();
    _currentIndexSubscription?.cancel();

    log(
      'close: Disposing orchestrator and player service',
      name: 'TrackPlayerCubit',
    );
    _preCachingOrchestrator.dispose();
    _playerService.dispose();

    log('close: TrackPlayerCubit closed', name: 'TrackPlayerCubit');
    return super.close();
  }
}
