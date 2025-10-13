import 'dart:async';
import 'dart:developer';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_cache_repository.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

/// Value object reprezentujący progress cache'owania.
/// Immutable snapshot używany do komunikacji z UI.
class CacheProgress {
  final Map<int, CacheStatus> tracksCacheStatus;

  CacheProgress(this.tracksCacheStatus);

  /// Liczba tracków które zostały już cache'owane.
  int get cachedCount =>
      tracksCacheStatus.values.where((s) => s == CacheStatus.cached).length;

  /// Całkowita liczba tracków do cache'owania.
  int get totalCount => tracksCacheStatus.length;

  /// Czy cache'owanie zostało zakończone (wszystkie tracki przetworzone).
  bool get isComplete => tracksCacheStatus.values.every(
    (s) => s != CacheStatus.notStarted && s != CacheStatus.caching,
  );
}

/// Orchestrator odpowiedzialny za background pre-caching wszystkich tracków w projekcie.
/// Enkapsuluje logikę cache'owania i progress tracking, komunikując się z UI przez stream.
class AudioPreCachingOrchestrator {
  final AudioCacheRepository _cacheRepo;

  // Stream do komunikacji z UI o progress
  final _progressController = StreamController<CacheProgress>.broadcast();

  /// Stream emitujący progress updates podczas cache'owania.
  Stream<CacheProgress> get progressStream => _progressController.stream;

  AudioPreCachingOrchestrator({
    required AudioCacheRepository cacheRepo,
  }) : _cacheRepo = cacheRepo;

  /// Rozpoczyna pre-caching wszystkich tracków.
  /// Sprawdza najpierw które tracki są już w cache, a następnie
  /// cache'uje tylko te które nie są cached.
  /// Progress jest emitowany przez progressStream.
  Future<void> preCacheTracks(List<Track> tracks) async {
    log(
      'preCacheTracks: Starting for ${tracks.length} tracks',
      name: 'AudioPreCachingOrchestrator',
    );

    // 1. Sprawdź które tracki są już w cache
    final tracksCacheStatus = <int, CacheStatus>{};
    for (final track in tracks) {
      final url = track.mainVersion?.file?.downloadUrl;

      if (url == null) {
        tracksCacheStatus[track.id] = CacheStatus.noFile;
        log(
          'preCacheTracks: Track ${track.id} has no download URL',
          name: 'AudioPreCachingOrchestrator',
        );
        continue;
      }

      // Sprawdź czy już w cache
      final isCached = await _cacheRepo.isCached(track.id);
      tracksCacheStatus[track.id] = isCached
          ? CacheStatus.cached
          : CacheStatus.notStarted;

      log(
        'preCacheTracks: Track ${track.id} cache status: ${isCached ? "cached" : "not cached"}',
        name: 'AudioPreCachingOrchestrator',
      );
    }

    // 2. Emit initial progress (user od razu widzi co jest cached)
    final cachedCount = tracksCacheStatus.values
        .where((s) => s == CacheStatus.cached)
        .length;
    log(
      'preCacheTracks: Found $cachedCount/${tracks.length} already cached',
      name: 'AudioPreCachingOrchestrator',
    );
    _emitProgress(tracksCacheStatus);

    // 3. Cache tylko te które nie są cached
    for (final track in tracks) {
      if (tracksCacheStatus[track.id] == CacheStatus.notStarted) {
        await _cacheTrack(track, tracksCacheStatus);
      }
    }

    log(
      'preCacheTracks: Completed',
      name: 'AudioPreCachingOrchestrator',
    );
  }

  /// Cache'uje pojedynczy track i aktualizuje status.
  Future<void> _cacheTrack(
    Track track,
    Map<int, CacheStatus> statusMap,
  ) async {
    final trackId = track.id;
    final url = track.mainVersion?.file?.downloadUrl;

    if (url == null) {
      // Track nie ma pliku - ustaw status noFile
      statusMap[trackId] = CacheStatus.noFile;
      log(
        'Track $trackId has no download URL, skipping cache',
        name: 'AudioPreCachingOrchestrator',
      );
      _emitProgress(statusMap);
      return;
    }

    try {
      // Update status na caching
      statusMap[trackId] = CacheStatus.caching;
      _emitProgress(statusMap);

      // Downloaduj plik do cache
      await _cacheRepo.downloadToCache(url, trackId);

      // Update status na cached
      statusMap[trackId] = CacheStatus.cached;
      log(
        'Successfully cached track $trackId',
        name: 'AudioPreCachingOrchestrator',
      );
      _emitProgress(statusMap);
    } catch (e) {
      // Update status na error
      statusMap[trackId] = CacheStatus.error;
      log(
        'Failed to cache track $trackId: $e. Track will stream instead.',
        name: 'AudioPreCachingOrchestrator',
      );
      _emitProgress(statusMap);
      // Graceful degradation: nie rethrow - kontynuuj cache'owanie pozostałych
    }
  }

  /// Emituje progress update przez stream.
  void _emitProgress(Map<int, CacheStatus> statusMap) {
    _progressController.add(CacheProgress(statusMap));
  }

  /// Invaliduje cache dla danego tracka (usuwa plik z dysku).
  /// Używane gdy zmienia się główna wersja tracka - stary cache musi zostać usunięty.
  Future<void> invalidateTrackCache(int trackId) async {
    log(
      'Invalidating cache for track $trackId',
      name: 'AudioPreCachingOrchestrator',
    );
    await _cacheRepo.clearTrackCache(trackId);
  }

  /// Aktualizuje cache dla tracka po zmianie wersji.
  /// Invaliduje stary cache i opcjonalnie pre-cache'uje nową wersję w tle.
  Future<void> updateTrackCache(Track track) async {
    log(
      'Updating cache for track ${track.id}',
      name: 'AudioPreCachingOrchestrator',
    );

    // Invaliduj stary cache
    await invalidateTrackCache(track.id);

    // Pre-cache'uj nową wersję w background (best-effort)
    final url = track.mainVersion?.file?.downloadUrl;
    if (url != null) {
      // Uruchom download w background - nie czekamy na zakończenie
      unawaited(_cacheRepo.downloadToCache(url, track.id));
      log(
        'Started background caching for track ${track.id}',
        name: 'AudioPreCachingOrchestrator',
      );
    } else {
      log(
        'Track ${track.id} has no download URL, skipping pre-caching',
        name: 'AudioPreCachingOrchestrator',
      );
    }
  }

  /// Dispose stream controller.
  void dispose() {
    _progressController.close();
  }
}
