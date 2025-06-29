import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/repositories/song_repository.dart';
import 'package:bandspace_mobile/song_detail/cubit/audio_player_state.dart';

/// Cubit zarządzający odtwarzaczem audio
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final SongRepository songRepository;
  final AudioPlayer _audioPlayer;
  final int songId;
  
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  AudioPlayerCubit({
    required this.songRepository,
    required this.songId,
  })  : _audioPlayer = AudioPlayer(),
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
  void setPlaylist(List<SongFile> files) {
    emit(state.copyWith(
      playlist: files,
      currentIndex: 0,
    ));
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
      // Pobierz URL do streamowania
      final streamUrl = await songRepository.getFileDownloadUrl(
        songId: songId,
        fileId: state.currentFile!.fileId,
      );

      print('AudioPlayer: Trying to play URL: $streamUrl');

      // Załaduj i odtwórz plik
      await _audioPlayer.play(UrlSource(streamUrl));
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

  @override
  Future<void> close() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _audioPlayer.dispose();
    return super.close();
  }
}