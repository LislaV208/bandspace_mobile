import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

import 'audio_player_state.dart';

/// Cubit zarządzający stanem odtwarzacza audio.
/// Jest to generyczny, reużywalny komponent, niezależny od logiki biznesowej aplikacji.
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  /// Konstruktor nie przyjmuje żadnych zależności biznesowych.
  AudioPlayerCubit()
    : _audioPlayer = AudioPlayer(),
      super(const AudioPlayerState()) {
    _listenToPlayerEvents();
  }

  /// Prywatna metoda do nasłuchiwania na wszystkie zdarzenia z paczki `audioplayers`.
  void _listenToPlayerEvents() {
    // Nasłuchiwanie na zmiany stanu (playing, paused, completed)
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      playerState,
    ) {
      if (state.status == PlayerStatus.loading) {
        return; // Ignoruj zdarzenia podczas ładowania
      }

      switch (playerState) {
        case PlayerState.playing:
          emit(state.copyWith(status: PlayerStatus.playing));
          break;
        case PlayerState.paused:
          emit(state.copyWith(status: PlayerStatus.paused));
          break;
        case PlayerState.completed:
          // Po zakończeniu, ustawiamy status `completed` i przewijamy na początek
          emit(
            state.copyWith(
              status: PlayerStatus.completed,
              currentPosition: Duration.zero,
            ),
          );
          _audioPlayer.seek(Duration.zero);
          break;
        case PlayerState.stopped:
          emit(
            state.copyWith(
              status: PlayerStatus.idle,
              currentPosition: Duration.zero,
            ),
          );
          break;
        default:
          break;
      }
    });

    // Nasłuchiwanie na zmianę całkowitego czasu trwania pliku
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      emit(state.copyWith(totalDuration: duration));
    });

    // Nasłuchiwanie na zmianę aktualnej pozycji odtwarzania
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      // Aktualizuj pozycję tylko, gdy odtwarzamy lub pauzujemy, aby uniknąć skoków
      if (state.status == PlayerStatus.playing ||
          state.status == PlayerStatus.paused) {
        emit(state.copyWith(currentPosition: position));
      }
    });
  }

  // =======================================================
  // ===          PUBLICZNE API CUBITA                   ===
  // =======================================================

  /// Ładuje nowy plik audio z podanego URL i opcjonalnie rozpoczyna odtwarzanie.
  Future<void> loadUrl(String url, {bool playWhenReady = false}) async {
    // Jeśli próbujemy załadować ten sam plik, który jest już załadowany,
    // po prostu wznawiamy odtwarzanie.
    if (state.currentUrl == url &&
        state.status != PlayerStatus.idle &&
        state.status != PlayerStatus.error) {
      if (playWhenReady) await play();
      return;
    }

    emit(
      state.copyWith(
        status: PlayerStatus.loading,
        currentUrl: Value(url),
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
        errorMessage: Value(null), // Wyczyść poprzednie błędy
      ),
    );

    try {
      await _audioPlayer.setSourceUrl(url);
      if (playWhenReady) {
        await _audioPlayer.resume(); // resume() jest bezpieczniejsze niż play()
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
    }
  }

  /// Rozpoczyna lub wznawia odtwarzanie.
  Future<void> play() async {
    await _audioPlayer.resume();
  }

  /// Pauzuje odtwarzanie.
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Przewija do określonej pozycji w pliku.
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Zatrzymuje odtwarzanie i zwalnia zasoby związane z plikiem.
  /// Używane, gdy użytkownik chce całkowicie wyłączyć odtwarzacz.
  Future<void> stop() async {
    await _audioPlayer.stop();
    emit(const AudioPlayerState()); // Resetuj stan do początkowego
  }

  /// Metoda wywoływana, gdy Cubit jest niszczony.
  /// Kluczowe jest, aby zamknąć wszystkie subskrypcje i zwolnić zasoby odtwarzacza.
  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
