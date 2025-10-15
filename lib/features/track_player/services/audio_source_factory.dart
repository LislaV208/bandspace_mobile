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
    final startTime = DateTime.now();
    log(
      'createAudioSource: START for track $trackId',
      name: 'AudioSourceFactory',
    );

    try {
      final getCacheFileStart = DateTime.now();
      final cacheFile = await _cacheRepo.getCacheFile(trackId);
      final getCacheFileDuration = DateTime.now().difference(getCacheFileStart);
      log(
        'createAudioSource: getCacheFile() took ${getCacheFileDuration.inMilliseconds}ms',
        name: 'AudioSourceFactory',
      );

      final createSourceStart = DateTime.now();
      // LockCachingAudioSource automatycznie fallback'uje do streaming
      // jeśli cache file nie istnieje
      final source = LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: cacheFile,
      );
      final createSourceDuration = DateTime.now().difference(createSourceStart);
      log(
        'createAudioSource: LockCachingAudioSource creation took ${createSourceDuration.inMilliseconds}ms',
        name: 'AudioSourceFactory',
      );

      final totalDuration = DateTime.now().difference(startTime);
      log(
        'createAudioSource: COMPLETE for track $trackId - TOTAL TIME: ${totalDuration.inMilliseconds}ms',
        name: 'AudioSourceFactory',
      );

      return source;
    } catch (e) {
      final totalDuration = DateTime.now().difference(startTime);
      // Jeśli cokolwiek pójdzie nie tak (brak cache, błąd file system, etc.)
      // fallback do pure streaming
      log(
        'createAudioSource: FAILED for track $trackId after ${totalDuration.inMilliseconds}ms: $e. '
        'Falling back to streaming.',
        name: 'AudioSourceFactory',
      );

      return AudioSource.uri(Uri.parse(url));
    }
  }
}
