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
