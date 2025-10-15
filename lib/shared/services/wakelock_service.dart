import 'dart:developer' as developer;

import 'package:wakelock_plus/wakelock_plus.dart';

/// Serwis zarządzający Wake Lock w aplikacji.
///
/// Enkapsuluje zależność od WakelockPlus i zapewnia kontrolowane API
/// do zapobiegania uśpieniu ekranu urządzenia podczas krytycznych operacji
/// (np. upload plików, odtwarzanie audio).
///
/// Serwis śledzi aktualny stan Wake Lock i zapobiega redundantnym wywołaniom.
class WakelockService {
  bool _isEnabled = false;

  /// Zwraca true jeśli Wake Lock jest obecnie włączony.
  bool get isEnabled => _isEnabled;

  /// Włącza Wake Lock, aby zapobiec uśpieniu ekranu urządzenia.
  ///
  /// Parametr [reason] powinien opisywać powód włączenia Wake Lock
  /// (np. 'audio playback', 'file upload'). Używany do logowania.
  ///
  /// Jeśli Wake Lock jest już włączony, metoda nie wykonuje żadnej operacji.
  ///
  /// Przykład:
  /// ```dart
  /// await wakelockService.enable(reason: 'audio playback');
  /// ```
  Future<void> enable({String? reason}) async {
    if (_isEnabled) {
      developer.log(
        'Wake Lock already enabled, skipping enable call',
        name: 'WakelockService',
      );
      return;
    }

    try {
      await WakelockPlus.enable();
      _isEnabled = true;
      developer.log(
        'Wake Lock enabled${reason != null ? ': $reason' : ''}',
        name: 'WakelockService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to enable Wake Lock: $e',
        name: 'WakelockService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Wyłącza Wake Lock, pozwalając urządzeniu na normalne uśpienie ekranu.
  ///
  /// Parametr [reason] powinien opisywać powód wyłączenia Wake Lock.
  /// Używany do logowania.
  ///
  /// Jeśli Wake Lock jest już wyłączony, metoda nie wykonuje żadnej operacji.
  ///
  /// Przykład:
  /// ```dart
  /// await wakelockService.disable(reason: 'audio stopped');
  /// ```
  Future<void> disable({String? reason}) async {
    if (!_isEnabled) {
      developer.log(
        'Wake Lock already disabled, skipping disable call',
        name: 'WakelockService',
      );
      return;
    }

    try {
      await WakelockPlus.disable();
      _isEnabled = false;
      developer.log(
        'Wake Lock disabled${reason != null ? ': $reason' : ''}',
        name: 'WakelockService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to disable Wake Lock: $e',
        name: 'WakelockService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Włącza Wake Lock tymczasowo na czas wykonywania operacji [operation].
  ///
  /// Automatycznie wyłącza Wake Lock po zakończeniu operacji (sukces lub błąd).
  /// Użyj tej metody dla krótkotrwałych operacji, gdzie chcesz zagwarantować
  /// że Wake Lock zostanie wyłączony.
  ///
  /// Parametr [reason] opisuje powód włączenia Wake Lock (dla logowania).
  ///
  /// Przykład:
  /// ```dart
  /// await wakelockService.runWithWakelock(
  ///   reason: 'file upload',
  ///   operation: () => uploadFile(),
  /// );
  /// ```
  Future<T> runWithWakelock<T>({
    required Future<T> Function() operation,
    String? reason,
  }) async {
    await enable(reason: reason);
    try {
      return await operation();
    } finally {
      await disable(reason: reason);
    }
  }
}
