import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Opisuje, co odtwarzacz audio robi w danym momencie.
enum PlayerStatus {
  /// Odtwarzacz nic nie robi i nie ma załadowanego pliku.
  idle,

  /// Trwa proces ładowania i dekodowania pliku audio z sieci.
  loading,

  /// Plik jest załadowany i gotowy do odtworzenia.
  ready,

  /// Plik jest aktywnie odtwarzany.
  playing,

  /// Odtwarzanie jest wstrzymane przez użytkownika.
  paused,

  /// Odtwarzanie pliku dobiegło końca.
  completed,

  /// Wystąpił błąd podczas ładowania lub odtwarzania.
  error,
}

/// Reprezentuje kompletny stan odtwarzacza audio w danym momencie.
class AudioPlayerState extends Equatable {
  /// Aktualny status operacyjny odtwarzacza.
  final PlayerStatus status;

  /// URL aktualnie załadowanego lub ładowanego pliku audio.
  final String? currentUrl;

  /// Aktualna pozycja głowicy odtwarzającej.
  final Duration currentPosition;

  /// Całkowity czas trwania załadowanego pliku audio.
  final Duration totalDuration;

  /// Komunikat o błędzie, jeśli wystąpił.
  final String? errorMessage;

  /// Czy plik jest gotowy do odtworzenia (załadowany i zdekodowany).
  final bool isReady;

  /// Pozycja do której został zbuforowany audio (w Duration).
  final Duration bufferedPosition;

  /// Czy użytkownik obecnie przesuwa suwak.
  final bool isSeeking;

  /// Tymczasowa pozycja suwaka podczas przesuwania.
  final Duration? seekPosition;

  const AudioPlayerState({
    this.status = PlayerStatus.idle,
    this.currentUrl,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
    this.isReady = false,
    this.bufferedPosition = Duration.zero,
    this.isSeeking = false,
    this.seekPosition,
  });

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    // Podczas przesuwania użyj seekPosition, w przeciwnym razie currentPosition
    final position = isSeeking && seekPosition != null
        ? seekPosition!
        : currentPosition;
    return position.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// Tworzy kopię stanu, modyfikując tylko wybrane pola.
  AudioPlayerState copyWith({
    PlayerStatus? status,
    Value<String?>? currentUrl,
    Duration? currentPosition,
    Duration? totalDuration,
    Value<String?>? errorMessage,
    bool? isReady,
    Duration? bufferedPosition,
    bool? isSeeking,
    Value<Duration?>? seekPosition,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentUrl: currentUrl != null ? currentUrl.value : this.currentUrl,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
      isReady: isReady ?? this.isReady,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isSeeking: isSeeking ?? this.isSeeking,
      seekPosition: seekPosition != null
          ? seekPosition.value
          : this.seekPosition,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUrl,
    currentPosition,
    totalDuration,
    errorMessage,
    isReady,
    bufferedPosition,
    isSeeking,
    seekPosition,
  ];
}
