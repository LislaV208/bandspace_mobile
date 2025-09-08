import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackPlayerCubit extends Cubit<TrackPlayerState> {
  final ProjectsRepository _projectsRepository;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, int> _trackIdToPlayerIndex = {};

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _sequenceStateSubscription;
  StreamSubscription<List<Track>>? _tracksSubscription;

  TrackPlayerCubit({required ProjectsRepository projectsRepository})
    : _projectsRepository = projectsRepository,
      super(const TrackPlayerState()) {
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

    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((
      playerIndex,
    ) {
      if (playerIndex == null) {
        return;
      }

      final entry = _trackIdToPlayerIndex.entries.firstWhere(
        (entry) => entry.value == playerIndex,
        orElse: () => const MapEntry(-1, -1),
      );

      if (entry.key != -1) {
        final trackId = entry.key;
        final mainListIndex = state.tracks.indexWhere((t) => t.id == trackId);
        if (mainListIndex != -1 && state.currentTrackIndex != mainListIndex) {
          emit(state.copyWith(currentTrackIndex: mainListIndex));
        }
      }
    });

    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen((
      sequenceState,
    ) {
      final currentIndex = sequenceState.currentIndex;
      if (currentIndex == null) return;

      final hasNext = currentIndex < sequenceState.effectiveSequence.length - 1;
      final hasPrevious = currentIndex > 0;

      emit(
        state.copyWith(
          hasNext: hasNext,
          hasPrevious: hasPrevious,
        ),
      );
    });
  }

  Future<void> loadProjectTracks(int projectId, int initialTrackId) async {
    if (state.fetchStatus == FetchStatus.loading ||
        state.fetchStatus == FetchStatus.refreshing) {
      return;
    }

    await _tracksSubscription?.cancel();

    final response = await _projectsRepository.getTracks(projectId);
    final cachedTracks = response.cached;

    if (cachedTracks != null) {
      emit(state.copyWith(fetchStatus: FetchStatus.refreshing));
      await _processTracks(cachedTracks, initialTrackId, isInitialLoad: true);
    } else {
      emit(state.copyWith(fetchStatus: FetchStatus.loading));
    }

    _tracksSubscription = response.stream.listen(
      (tracks) {
        _processTracks(tracks, initialTrackId);
      },
      onError: (error) {
        emit(
          state.copyWith(
            fetchStatus: FetchStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
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
        final audioSource = await _createCachingAudioSource(url);
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
        fetchStatus: FetchStatus.success,
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

    final track = state.tracks[index];
    emit(state.copyWith(currentTrackIndex: index));

    final playerIndex = _trackIdToPlayerIndex[track.id];

    if (playerIndex != null) {
      _audioPlayer.seek(Duration.zero, index: playerIndex);
      _audioPlayer.play();
    } else {
      _audioPlayer.stop();
    }
  }

  void togglePlayPause() {
    if (state.playerUiStatus == PlayerUiStatus.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void seekToNext() {
    _audioPlayer.seekToNext();
  }

  void seekToPrevious() {
    _audioPlayer.seekToPrevious();
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

  Future<AudioSource> _createCachingAudioSource(String url) async {
    final cacheDir = await getTemporaryDirectory();
    final audioDir = Directory('${cacheDir.path}/audio_cache');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    final uri = Uri.parse(url);
    final baseUrl = uri.origin + uri.path;
    final urlHash = sha256.convert(baseUrl.codeUnits).toString();
    final cacheFile = File('${audioDir.path}/$urlHash.cache');

    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: cacheFile,
    );
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    _tracksSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
