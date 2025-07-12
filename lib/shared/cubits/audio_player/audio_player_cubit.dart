import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/player_status.dart';

import 'audio_player_state.dart';

/// Cubit zarządzający stanem odtwarzacza audio z obsługą playlist.
/// Niezależna implementacja z własnym AudioPlayer i pełną funkcjonalnością playlist.
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;

  // Subskrypcje dla podstawowych funkcji audio (skopiowane z AudioPlayerCubit)
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  // Subskrypcje dla funkcji playlist
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _sequenceStateSubscription;

  /// Konstruktor nie przyjmuje żadnych zależności biznesowych.
  AudioPlayerCubit()
    : _audioPlayer = AudioPlayer(),
      super(const AudioPlayerState()) {
    _listenToPlayerEvents();
    _listenToPlaylistEvents();
  }

  /// Prywatna metoda do nasłuchiwania na wszystkie zdarzenia z paczki `just_audio`.
  /// Skopiowane z AudioPlayerCubit i dostosowane do PlaylistAudioPlayerState.
  void _listenToPlayerEvents() {
    // Nasłuchiwanie na zmiany stanu (playing, paused, completed)
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      log(
        'PlaylistAudioPlayerCubit: Player state changed: ${playerState.processingState}',
      );

      switch (playerState.processingState) {
        case ProcessingState.idle:
          emit(
            state.copyWith(
              status: PlayerStatus.idle,
              currentPosition: Duration.zero,
              isReady: false,
            ),
          );
          break;
        case ProcessingState.loading:
          emit(state.copyWith(status: PlayerStatus.loading));
          break;
        case ProcessingState.buffering:
          // W just_audio buffering to oddzielny stan - możemy zachować obecny status
          break;
        case ProcessingState.ready:
          // Plik gotowy - ustaw odpowiedni status na podstawie playing
          final newStatus = playerState.playing
              ? PlayerStatus.playing
              : PlayerStatus.ready;
          emit(
            state.copyWith(
              status: newStatus,
              isReady: true,
            ),
          );
          break;
        case ProcessingState.completed:
          // Automatyczne przechodzenie do następnego utworu po zakończeniu (tylko w trybie playlist)
          if (state.hasPlaylist && state.canPlayNext) {
            _handleTrackCompleted();
          } else {
            emit(
              state.copyWith(
                status: PlayerStatus.completed,
                currentPosition: Duration.zero,
              ),
            );
          }
          break;
      }
    });

    // Nasłuchiwanie na zmianę całkowitego czasu trwania pliku
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        emit(
          state.copyWith(
            totalDuration: duration,
            isReady: true,
          ),
        );
      }
    });

    // Nasłuchiwanie na zmianę aktualnej pozycji odtwarzania
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      // Aktualizuj pozycję tylko, gdy odtwarzamy, pauzujemy lub jesteśmy gotowi, ale nie podczas przesuwania
      if (!state.isSeeking &&
          (state.status == PlayerStatus.playing ||
              state.status == PlayerStatus.paused ||
              state.status == PlayerStatus.ready)) {
        emit(state.copyWith(currentPosition: position));
      }
    });

    // Nasłuchiwanie na zmianę pozycji bufferowania
    _bufferedPositionSubscription = _audioPlayer.bufferedPositionStream.listen((
      bufferedPosition,
    ) {
      emit(state.copyWith(bufferedPosition: bufferedPosition));
    });
  }

  /// Nasłuchuje na zdarzenia specyficzne dla playlist
  void _listenToPlaylistEvents() {
    // Nasłuchiwanie na zmiany indeksu w playlist
    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (state.hasPlaylist) {
        emit(state.copyWith(currentIndex: Value(index)));

        // Aktualizuj currentUrl na podstawie nowego indeksu
        if (index != null && index < state.playlist.length) {
          emit(state.copyWith(currentUrl: Value(state.playlist[index])));
        }
      }
    });

    // Nasłuchiwanie na zmiany sekwencji (playlist)
    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen((
      sequenceState,
    ) {
      emit(
        state.copyWith(
          isShuffleEnabled: sequenceState.shuffleModeEnabled,
          loopMode: _audioPlayer.loopMode,
        ),
      );
    });
  }

  /// Obsługuje zakończenie utworu w trybie playlist
  void _handleTrackCompleted() async {
    switch (state.loopMode) {
      case LoopMode.one:
        // Odtwórz ten sam utwór ponownie
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
        break;
      default:
        // Przejdź do następnego utworu
        await playNext();
        break;
    }
  }

  // =======================================================
  // ===          PUBLICZNE API POJEDYNCZYCH PLIKÓW      ===
  // =======================================================

  /// Ładuje nowy plik audio z podanego URL i opcjonalnie rozpoczyna odtwarzanie.
  /// Skopiowane z AudioPlayerCubit z dodanym czyszczeniem playlist.
  Future<void> loadUrl(String url, {bool playWhenReady = false}) async {
    // Jeśli próbujemy załadować ten sam plik, który jest już załadowany,
    // po prostu wznawiamy odtwarzanie.
    if (state.currentUrl == url &&
        state.status != PlayerStatus.idle &&
        state.status != PlayerStatus.error) {
      if (playWhenReady) await play();
      return;
    }

    // Wyczyść playlist gdy ładujemy pojedynczy plik
    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentUrl: Value(url),
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
        errorMessage: Value(null),
        isReady: false,
        bufferedPosition: Duration.zero,
        // Wyczyść playlist
        playlist: [],
        currentIndex: Value(null),
        hasPlaylist: false,
        isShuffleEnabled: false,
        loopMode: LoopMode.off,
      ),
    );

    try {
      await _audioPlayer.setUrl(url);
      if (playWhenReady) {
        await _audioPlayer.play();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: Value(e.toString()),
          isReady: false,
          bufferedPosition: Duration.zero,
        ),
      );
    }
  }

  /// Przełącza między odtwarzaniem a pauzą.
  /// Skopiowane z AudioPlayerCubit.
  Future<void> togglePlayPause() async {
    switch (state.status) {
      case PlayerStatus.playing:
        await pause();
        break;
      case PlayerStatus.paused:
        await play();
        break;
      case PlayerStatus.ready:
        await play();
        break;
      case PlayerStatus.completed:
        await _audioPlayer.seek(Duration.zero);
        await play();
        break;
      case PlayerStatus.idle:
      case PlayerStatus.loading:
      case PlayerStatus.error:
        // Nie możemy odtworzyć w tych stanach
        break;
    }
  }

  /// Rozpoczyna lub wznawia odtwarzanie.
  Future<void> play() async {
    await _audioPlayer.play();
  }

  /// Pauzuje odtwarzanie.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Rozpoczyna przesuwanie suwaka - nie wykonuje jeszcze seek()
  void startSeeking() {
    emit(
      state.copyWith(
        isSeeking: true,
        seekPosition: Value(state.currentPosition),
      ),
    );
  }

  /// Aktualizuje pozycję suwaka podczas przesuwania
  void updateSeekPosition(double value) {
    if (!state.isSeeking) return;

    final newPosition = Duration(
      milliseconds: (value * state.totalDuration.inMilliseconds).round(),
    );

    emit(
      state.copyWith(
        seekPosition: Value(newPosition),
      ),
    );
  }

  /// Kończy przesuwanie i wykonuje faktyczny seek()
  Future<void> endSeeking() async {
    if (!state.isSeeking || state.seekPosition == null) return;

    final targetPosition = state.seekPosition!;

    // Zakończ tryb seeking
    emit(
      state.copyWith(
        isSeeking: false,
        seekPosition: Value(null),
        currentPosition: targetPosition,
      ),
    );

    // Wykonaj faktyczny seek
    await _audioPlayer.seek(targetPosition);
  }

  /// Przewija do określonej pozycji w pliku (natychmiastowy seek)
  /// `value` to wartość z zakresu 0.0 - 1.0
  Future<void> seek(double value) async {
    await _audioPlayer.seek(
      Duration(
        milliseconds: (value * state.totalDuration.inMilliseconds).round(),
      ),
    );
  }

  /// Zatrzymuje odtwarzanie i zwalnia zasoby związane z plikiem.
  /// Używane, gdy użytkownik chce całkowicie wyłączyć odtwarzacz.
  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(
      const AudioPlayerState(),
    ); // Resetuj stan do początkowego
  }

  // =======================================================
  // ===          PUBLICZNE API PLAYLIST                 ===
  // =======================================================

  /// Ładuje playlist z podanych URL-i
  Future<void> loadPlaylist(
    List<String> urls, {
    int? initialIndex,
    bool playWhenReady = false,
  }) async {
    if (urls.isEmpty) {
      await clearPlaylist();
      return;
    }

    try {
      // Tworzenie AudioSource dla każdego URL
      final audioSources = urls
          .map((url) => AudioSource.uri(Uri.parse(url)))
          .toList();

      // Aktualizuj stan z nową playlist
      emit(
        state.copyWith(
          status: PlayerStatus.loading,
          playlist: urls,
          currentIndex: Value(initialIndex ?? 0),
          hasPlaylist: true,
          errorMessage: Value(null),
          isReady: false,
        ),
      );

      // Załaduj playlist w just_audio
      await _audioPlayer.setAudioSources(
        audioSources,
        initialIndex: initialIndex ?? 0,
        initialPosition: Duration.zero,
      );

      if (playWhenReady) {
        await _audioPlayer.play();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: Value(e.toString()),
          isReady: false,
        ),
      );
    }
  }

  /// Przechodzi do następnego utworu w playlist
  Future<void> playNext() async {
    if (!state.hasPlaylist || !state.canPlayNext) return;

    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      log('Error playing next track: $e');
    }
  }

  /// Przechodzi do poprzedniego utworu w playlist
  Future<void> playPrevious() async {
    if (!state.hasPlaylist || !state.canPlayPrevious) return;

    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      log('Error playing previous track: $e');
    }
  }

  /// Przechodzi do konkretnego utworu w playlist
  Future<void> playTrackAt(int index) async {
    if (!state.hasPlaylist || index < 0 || index >= state.playlist.length) {
      return;
    }

    try {
      await _audioPlayer.seek(Duration.zero, index: index);
    } catch (e) {
      log('Error playing track at index $index: $e');
    }
  }

  /// Włącza/wyłącza tryb shuffle
  Future<void> setShuffleMode(bool enabled) async {
    try {
      await _audioPlayer.setShuffleModeEnabled(enabled);
      emit(state.copyWith(isShuffleEnabled: enabled));
    } catch (e) {
      log('Error setting shuffle mode: $e');
    }
  }

  /// Ustawia tryb zapętlenia
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await _audioPlayer.setLoopMode(loopMode);
      emit(state.copyWith(loopMode: loopMode));
    } catch (e) {
      log('Error setting loop mode: $e');
    }
  }

  /// Dodaje nowy utwór do playlist
  Future<void> addToPlaylist(String url, {int? atIndex}) async {
    if (!state.hasPlaylist) return;

    try {
      final audioSource = AudioSource.uri(Uri.parse(url));

      if (atIndex != null) {
        await _audioPlayer.insertAudioSource(atIndex, audioSource);
      } else {
        await _audioPlayer.addAudioSource(audioSource);
      }

      // Aktualizuj lokalną listę URL-i
      final newPlaylist = List<String>.from(state.playlist);
      if (atIndex != null && atIndex >= 0 && atIndex <= newPlaylist.length) {
        newPlaylist.insert(atIndex, url);
      } else {
        newPlaylist.add(url);
      }

      emit(state.copyWith(playlist: newPlaylist));
    } catch (e) {
      log('Error adding to playlist: $e');
    }
  }

  /// Usuwa utwór z playlist
  Future<void> removeFromPlaylist(int index) async {
    if (!state.hasPlaylist || index < 0 || index >= state.playlist.length) {
      return;
    }

    try {
      await _audioPlayer.removeAudioSourceAt(index);

      // Aktualizuj lokalną listę URL-i
      final newPlaylist = List<String>.from(state.playlist);
      newPlaylist.removeAt(index);

      if (newPlaylist.isEmpty) {
        await clearPlaylist();
      } else {
        emit(state.copyWith(playlist: newPlaylist));
      }
    } catch (e) {
      log('Error removing from playlist: $e');
    }
  }

  /// Czyści playlist i powraca do trybu pojedynczego pliku
  Future<void> clearPlaylist() async {
    await _audioPlayer.stop();
    emit(
      state.copyWith(
        playlist: [],
        currentIndex: Value(null),
        hasPlaylist: false,
        isShuffleEnabled: false,
        loopMode: LoopMode.off,
      ),
    );
  }

  /// Metoda wywoływana, gdy Cubit jest niszczony.
  /// Kluczowe jest, aby zamknąć wszystkie subskrypcje i zwolnić zasoby odtwarzacza.
  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
