import 'dart:developer';

import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/features/track_player/services/audio_cache_repository.dart';

/// Factory odpowiedzialny za tworzenie AudioSource objects z URL.
/// Implementuje graceful degradation - jeśli tworzenie caching source się nie powiedzie,
/// fallback do streaming.
class AudioSourceFactory {
  final AudioCacheRepository _cacheRepo;

  AudioSourceFactory({
    required AudioCacheRepository cacheRepo,
  }) : _cacheRepo = cacheRepo;

  /// Tworzy AudioSource dla danego URL i track ID.
  ///
  /// Strategia:
  /// 1. Próbuje utworzyć LockCachingAudioSource (cache + streaming fallback)
  /// 2. Jeśli się nie powiedzie, tworzy AudioSource.uri (pure streaming)
  ///
  /// Graceful degradation: użytkownik zawsze może odtwarzać track,
  /// nawet jeśli cache nie działa.
  Future<AudioSource> createAudioSource(String url, int trackId) async {
    try {
      final cacheFile = await _cacheRepo.getCacheFile(trackId);

      // LockCachingAudioSource automatycznie fallback'uje do streaming
      // jeśli cache file nie istnieje
      return LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: cacheFile,
      );
    } catch (e) {
      // Jeśli cokolwiek pójdzie nie tak (brak cache, błąd file system, etc.)
      // fallback do pure streaming
      log(
        'Failed to create caching audio source for track $trackId: $e. '
        'Falling back to streaming.',
        name: 'AudioSourceFactory',
      );

      return AudioSource.uri(Uri.parse(url));
    }
  }
}
