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
  bool get isComplete => tracksCacheStatus.values
      .every((s) => s != CacheStatus.notStarted && s != CacheStatus.caching);
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
  /// Cache'uje tracki sekwencyjnie, jeden po drugim.
  /// Progress jest emitowany przez progressStream.
  Future<void> preCacheTracks(List<Track> tracks) async {
    // Inicjalizuj status dla wszystkich tracków
    final tracksCacheStatus = <int, CacheStatus>{};
    for (final track in tracks) {
      tracksCacheStatus[track.id] = CacheStatus.notStarted;
    }

    // Emit initial progress
    _emitProgress(tracksCacheStatus);

    // Cache każdy track sekwencyjnie
    for (final track in tracks) {
      await _cacheTrack(track, tracksCacheStatus);
    }
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

  /// Dispose stream controller.
  void dispose() {
    _progressController.close();
  }
}
