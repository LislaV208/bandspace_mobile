import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

import 'audio_player_state.dart';

/// Cubit zarządzający stanem odtwarzacza audio.
/// Jest to generyczny, reużywalny komponent, niezależny od logiki biznesowej aplikacji.
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  /// Konstruktor nie przyjmuje żadnych zależności biznesowych.
  AudioPlayerCubit()
    : _audioPlayer = AudioPlayer(),
      super(const AudioPlayerState()) {
    _listenToPlayerEvents();
  }

  /// Prywatna metoda do nasłuchiwania na wszystkie zdarzenia z paczki `just_audio`.
  void _listenToPlayerEvents() {
    // Nasłuchiwanie na zmiany stanu (playing, paused, completed)
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      log(
        'AudioPlayerCubit: Player state changed: ${playerState.processingState}',
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
          emit(
            state.copyWith(
              status: PlayerStatus.completed,
              currentPosition: Duration.zero,
            ),
          );
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
        isReady: false,
        bufferedPosition: Duration.zero,
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
    ); // Resetuj stan do początkowego (isReady: false, bufferedPosition: zero)
  }

  /// Metoda wywoływana, gdy Cubit jest niszczony.
  /// Kluczowe jest, aby zamknąć wszystkie subskrypcje i zwolnić zasoby odtwarzacza.
  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
