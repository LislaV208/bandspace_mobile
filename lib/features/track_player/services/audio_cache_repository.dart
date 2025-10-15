import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Repository odpowiedzialny za zarządzanie cache'owaniem plików audio na dysku.
/// Enkapsuluje logikę związaną z file system i HTTP downloads.
class AudioCacheRepository {
  final Dio _dio;
  final int projectId;

  AudioCacheRepository({
    required Dio dio,
    required this.projectId,
  }) : _dio = dio;

  /// Zwraca File object reprezentujący lokalizację cache dla danego tracka.
  /// Tworzy katalog jeśli nie istnieje.
  Future<File> getCacheFile(int trackId) async {
    final startTime = DateTime.now();

    log(
      'getCacheFile: START for track $trackId',
      name: 'AudioCacheRepository',
    );

    final getTempDirStart = DateTime.now();
    final cacheDir = await getTemporaryDirectory();
    final getTempDirDuration = DateTime.now().difference(getTempDirStart);
    log(
      'getCacheFile: getTemporaryDirectory() took ${getTempDirDuration.inMilliseconds}ms',
      name: 'AudioCacheRepository',
    );

    final projectCacheDir = Directory(
      '${cacheDir.path}/audio_cache/project_$projectId',
    );

    final existsCheckStart = DateTime.now();
    final exists = await projectCacheDir.exists();
    final existsCheckDuration = DateTime.now().difference(existsCheckStart);
    log(
      'getCacheFile: directory.exists() took ${existsCheckDuration.inMilliseconds}ms, result=$exists',
      name: 'AudioCacheRepository',
    );

    if (!exists) {
      final createDirStart = DateTime.now();
      await projectCacheDir.create(recursive: true);
      final createDirDuration = DateTime.now().difference(createDirStart);
      log(
        'getCacheFile: directory.create() took ${createDirDuration.inMilliseconds}ms',
        name: 'AudioCacheRepository',
      );
    }

    final totalDuration = DateTime.now().difference(startTime);
    log(
      'getCacheFile: COMPLETE for track $trackId - TOTAL TIME: ${totalDuration.inMilliseconds}ms',
      name: 'AudioCacheRepository',
    );

    return File('${projectCacheDir.path}/track_$trackId.cache');
  }

  /// Sprawdza czy plik jest już w cache.
  Future<bool> isCached(int trackId) async {
    final startTime = DateTime.now();
    try {
      final getCacheFileStart = DateTime.now();
      final file = await getCacheFile(trackId);
      final getCacheFileDuration = DateTime.now().difference(getCacheFileStart);

      final existsCheckStart = DateTime.now();
      final exists = await file.exists();
      final existsCheckDuration = DateTime.now().difference(existsCheckStart);

      final totalDuration = DateTime.now().difference(startTime);
      log(
        'isCached: track $trackId - getCacheFile: ${getCacheFileDuration.inMilliseconds}ms, file.exists: ${existsCheckDuration.inMilliseconds}ms, total: ${totalDuration.inMilliseconds}ms, result=$exists',
        name: 'AudioCacheRepository',
      );

      return exists;
    } catch (e) {
      final totalDuration = DateTime.now().difference(startTime);
      log(
        'isCached: Failed to check cache status for track $trackId after ${totalDuration.inMilliseconds}ms: $e',
        name: 'AudioCacheRepository',
      );
      return false;
    }
  }

  /// Pobiera plik audio i zapisuje w cache.
  /// Jeśli plik już istnieje, pomija download (duplicate prevention).
  /// Rzuca exception jeśli download się nie powiedzie.
  Future<void> downloadToCache(String url, int trackId) async {
    final file = await getCacheFile(trackId);

    // Sprawdź czy plik już istnieje
    if (await file.exists()) {
      log(
        'Track $trackId already cached, skipping download',
        name: 'AudioCacheRepository',
      );
      return;
    }

    // Downloaduj plik używając Dio
    try {
      await _dio.download(url, file.path);
      log(
        'Downloaded track $trackId to cache',
        name: 'AudioCacheRepository',
      );
    } catch (e) {
      log(
        'Failed to download track $trackId: $e',
        name: 'AudioCacheRepository',
      );
      rethrow; // Repository nie decyduje o error handling strategy
    }
  }

  /// Usuwa cache dla danego tracka.
  Future<void> clearTrackCache(int trackId) async {
    try {
      final file = await getCacheFile(trackId);
      if (await file.exists()) {
        await file.delete();
        log(
          'Cleared cache for track $trackId',
          name: 'AudioCacheRepository',
        );
      }
    } catch (e) {
      log(
        'Failed to clear cache for track $trackId: $e',
        name: 'AudioCacheRepository',
      );
    }
  }

  /// Usuwa całą zawartość cache dla projektu (opcjonalne, na przyszłość).
  Future<void> clearProjectCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final projectCacheDir = Directory(
        '${cacheDir.path}/audio_cache/project_$projectId',
      );

      if (await projectCacheDir.exists()) {
        await projectCacheDir.delete(recursive: true);
        log(
          'Cleared all cache for project $projectId',
          name: 'AudioCacheRepository',
        );
      }
    } catch (e) {
      log(
        'Failed to clear project cache for project $projectId: $e',
        name: 'AudioCacheRepository',
      );
    }
  }
}
