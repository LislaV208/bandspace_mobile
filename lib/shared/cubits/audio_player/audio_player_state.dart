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

  /// Pozycja do której został zbuforowany audio (w Duration).
  final Duration bufferedPosition;

  const AudioPlayerState({
    this.status = PlayerStatus.idle,
    this.currentUrl,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.errorMessage,
    this.bufferedPosition = Duration.zero,
  });

  /// Tworzy kopię stanu, modyfikując tylko wybrane pola.
  AudioPlayerState copyWith({
    PlayerStatus? status,
    Value<String?>? currentUrl,
    Duration? currentPosition,
    Duration? totalDuration,
    Value<String?>? errorMessage,
    Duration? bufferedPosition,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentUrl: currentUrl != null ? currentUrl.value : this.currentUrl,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentUrl,
    currentPosition,
    totalDuration,
    errorMessage,
    bufferedPosition,
  ];
}
