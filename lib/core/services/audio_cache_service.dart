import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import 'package:bandspace_mobile/core/models/cached_audio_file.dart';
import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/services/audio_cache_database.dart';

/// Konfiguracja cache audio
class AudioCacheConfig {
  /// Maksymalny rozmiar cache w bajtach (domyślnie 2GB)
  final int maxCacheSize;
  
  /// Maksymalna liczba plików w cache
  final int maxFileCount;
  
  /// Automatyczne czyszczenie cache przy przekroczeniu limitu
  final bool autoCleanup;
  
  /// Procent cache do usunięcia podczas cleanup (0.0 - 1.0)
  final double cleanupPercentage;
  
  /// Maksymalny czas oczekiwania na pobieranie w sekundach
  final int downloadTimeoutSeconds;
  
  /// Maksymalna liczba jednoczesnych pobierań
  final int maxConcurrentDownloads;

  const AudioCacheConfig({
    this.maxCacheSize = 2 * 1024 * 1024 * 1024, // 2GB
    this.maxFileCount = 1000,
    this.autoCleanup = true,
    this.cleanupPercentage = 0.2, // Usuń 20% najstarszych plików
    this.downloadTimeoutSeconds = 300, // 5 minut
    this.maxConcurrentDownloads = 3,
  });
}

/// Serwis odpowiedzialny za cache'owanie plików audio
class AudioCacheService {
  final AudioCacheDatabase _database;
  final Dio _dio;
  AudioCacheConfig _config;
  
  /// Mapa aktywnych pobierań
  final Map<int, CancelToken> _activeDownloads = {};
  
  /// Kontrolery dla streamów postępu
  final Map<int, StreamController<DownloadProgress>> _progressControllers = {};
  
  /// Liczba aktywnych pobierań
  int get activeDownloadCount => _activeDownloads.length;

  /// Singleton instance
  static final AudioCacheService _instance = AudioCacheService._internal();
  
  /// Factory zwracająca singleton
  factory AudioCacheService({AudioCacheConfig? config}) {
    if (config != null) {
      _instance._config = config;
    }
    return _instance;
  }
  
  /// Konstruktor prywatny
  AudioCacheService._internal()
      : _database = AudioCacheDatabase(),
        _dio = Dio(),
        _config = const AudioCacheConfig() {
    _setupDio();
  }

  /// Konfiguruje instancję Dio
  void _setupDio() {
    _dio.options.connectTimeout = Duration(seconds: _config.downloadTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: _config.downloadTimeoutSeconds);
  }

  // =============== DOWNLOAD MANAGEMENT ===============

  /// Pobiera plik i zapisuje w cache
  Future<String?> downloadFile(SongFile songFile, String downloadUrl) async {
    final fileId = songFile.fileId;
    
    // Sprawdź czy plik już nie jest pobierany
    if (_activeDownloads.containsKey(fileId)) {
      throw Exception('Plik jest już pobierany');
    }

    // Sprawdź limit jednoczesnych pobierań
    if (activeDownloadCount >= _config.maxConcurrentDownloads) {
      throw Exception('Osiągnięto limit jednoczesnych pobierań (${_config.maxConcurrentDownloads})');
    }

    // Sprawdź czy plik już istnieje w cache
    final existingFile = await _database.getFile(fileId);
    if (existingFile?.isAvailableOffline == true) {
      return existingFile!.localPath;
    }

    try {
      // Utwórz lub zaktualizuj wpis w bazie danych
      final cacheFile = CachedAudioFile(
        fileId: fileId,
        songId: songFile.songId,
        filename: songFile.fileInfo.filename,
        fileKey: songFile.fileInfo.fileKey,
        mimeType: songFile.fileInfo.mimeType,
        size: songFile.fileInfo.size,
        status: CacheStatus.downloading,
        downloadedAt: DateTime.now(),
      );
      
      await _database.insertOrUpdate(cacheFile);

      // Pobierz plik
      final localPath = await _downloadFileToCache(songFile, downloadUrl);
      
      if (localPath != null) {
        // Aktualizuj bazę danych z lokalną ścieżką
        await _database.updateLocalPath(fileId, localPath);
      }
      
      return localPath;
    } catch (e) {
      // Zaktualizuj status na błąd
      await _database.updateFileStatus(fileId, CacheStatus.error);
      rethrow;
    }
  }

  /// Pobiera plik do cache
  Future<String?> _downloadFileToCache(SongFile songFile, String downloadUrl) async {
    final fileId = songFile.fileId;
    final cancelToken = CancelToken();
    _activeDownloads[fileId] = cancelToken;

    // Utwórz kontroler postępu
    final progressController = StreamController<DownloadProgress>.broadcast();
    _progressControllers[fileId] = progressController;

    try {
      // Uzyskaj ścieżkę do katalogu cache
      final cacheDir = await _getCacheDirectory();
      final localPath = path.join(cacheDir.path, '${fileId}_${songFile.fileInfo.filename}');

      // Rozpocznij pobieranie
      progressController.add(DownloadProgress.started(fileId, songFile.fileInfo.size));

      final stopwatch = Stopwatch()..start();
      int lastBytes = 0;

      await _dio.download(
        downloadUrl,
        localPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            
            // Oblicz prędkość pobierania
            final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000;
            final downloadSpeed = elapsedSeconds > 0 ? (received - lastBytes) / elapsedSeconds : 0.0;
            
            // Szacuj czas pozostały
            final remainingBytes = total - received;
            final estimatedTime = downloadSpeed > 0 ? (remainingBytes / downloadSpeed).round() : null;

            progressController.add(DownloadProgress(
              fileId: fileId,
              downloadedBytes: received,
              totalBytes: total,
              progress: progress,
              downloadSpeed: downloadSpeed,
              estimatedTimeRemaining: estimatedTime,
            ));

            lastBytes = received;
          }
        },
      );

      // Weryfikuj integralność pliku
      final file = File(localPath);
      if (await file.exists()) {
        final actualSize = await file.length();
        if (actualSize != songFile.fileInfo.size) {
          await file.delete();
          throw Exception('Rozmiar pliku nie zgadza się (oczekiwano: ${songFile.fileInfo.size}, otrzymano: $actualSize)');
        }

        // Oblicz sumę kontrolną
        final checksum = await _calculateChecksum(file);
        
        // Zaktualizuj plik z sumą kontrolną
        final cachedFile = await _database.getFile(fileId);
        if (cachedFile != null) {
          await _database.insertOrUpdate(
            cachedFile.copyWith(
              checksum: checksum,
              status: CacheStatus.cached,
            ),
          );
        }

        progressController.add(DownloadProgress.completed(fileId, songFile.fileInfo.size));
        return localPath;
      } else {
        throw Exception('Plik nie został utworzony');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        progressController.add(DownloadProgress(
          fileId: fileId,
          downloadedBytes: 0,
          totalBytes: 0,
          progress: 0.0,
          status: DownloadStatus.cancelled,
        ));
      } else {
        progressController.add(DownloadProgress.error(fileId, e.toString()));
      }
      rethrow;
    } finally {
      // Cleanup
      _activeDownloads.remove(fileId);
      await progressController.close();
      _progressControllers.remove(fileId);
    }
  }

  /// Anuluje pobieranie pliku
  Future<void> cancelDownload(int fileId) async {
    final cancelToken = _activeDownloads[fileId];
    if (cancelToken != null) {
      cancelToken.cancel('Pobieranie anulowane przez użytkownika');
      await _database.updateFileStatus(fileId, CacheStatus.notCached);
    }
  }

  // =============== CACHE QUERIES ===============

  /// Sprawdza czy plik jest cache'owany
  Future<bool> isFileCached(int fileId) async {
    final file = await _database.getFile(fileId);
    if (file?.isAvailableOffline != true) return false;

    // Sprawdź czy plik fizycznie istnieje
    if (file!.localPath != null) {
      final physicalFile = File(file.localPath!);
      return await physicalFile.exists();
    }
    
    return false;
  }

  /// Pobiera lokalną ścieżkę do cache'owanego pliku
  Future<String?> getLocalPath(int fileId) async {
    final file = await _database.getFile(fileId);
    if (file?.isAvailableOffline == true && file!.localPath != null) {
      final physicalFile = File(file.localPath!);
      if (await physicalFile.exists()) {
        // Aktualizuj czas ostatniego dostępu
        await _database.updateLastAccessed(fileId);
        return file.localPath;
      } else {
        // Plik nie istnieje fizycznie, zaktualizuj status
        await _database.updateFileStatus(fileId, CacheStatus.notCached);
      }
    }
    return null;
  }

  /// Pobiera informacje o cache'owanym pliku
  Future<CachedAudioFile?> getCachedFile(int fileId) async {
    return await _database.getFile(fileId);
  }

  /// Pobiera wszystkie cache'owane pliki dla utworu
  Future<List<CachedAudioFile>> getCachedFilesBySong(int songId) async {
    return await _database.getFilesBySong(songId);
  }

  // =============== CACHE SIZE MANAGEMENT ===============

  /// Pobiera całkowity rozmiar cache w bajtach
  Future<int> getCacheSize() async {
    return await _database.getTotalCacheSize();
  }

  /// Pobiera liczbę cache'owanych plików
  Future<int> getCachedFileCount() async {
    return await _database.getCachedFileCount();
  }

  /// Pobiera dostępne miejsce na urządzeniu
  Future<int> getAvailableSpace() async {
    try {
      await _getCacheDirectory(); // Upewniamy się, że katalog istnieje
      // Niestety Flutter nie dostarcza bezpośrednio informacji o dostępnym miejscu
      // Zwracamy duże wartości jako przybliżenie
      return 10 * 1024 * 1024 * 1024; // 10GB jako przybliżenie
    } catch (e) {
      return 0;
    }
  }

  /// Sprawdza czy potrzebny jest cleanup cache
  Future<bool> needsCleanup() async {
    final currentSize = await getCacheSize();
    final fileCount = await getCachedFileCount();
    
    return currentSize > _config.maxCacheSize || fileCount > _config.maxFileCount;
  }

  /// Czyści najstarsze pliki z cache (LRU strategy)
  Future<void> cleanupOldFiles() async {
    if (!await needsCleanup()) return;

    final filesToRemove = (_config.maxFileCount * _config.cleanupPercentage).round();
    final oldestFiles = await _database.getOldestFiles(limit: filesToRemove);

    for (final file in oldestFiles) {
      await deleteFile(file.fileId);
    }
  }

  /// Usuwa plik z cache
  Future<void> deleteFile(int fileId) async {
    final file = await _database.getFile(fileId);
    if (file?.localPath != null) {
      try {
        final physicalFile = File(file!.localPath!);
        if (await physicalFile.exists()) {
          await physicalFile.delete();
        }
      } catch (e) {
        // Ignoruj błędy usuwania pliku fizycznego
      }
    }
    
    await _database.deleteFile(fileId);
  }

  /// Czyści cały cache
  Future<void> clearCache() async {
    // Anuluj wszystkie aktywne pobierania
    for (final cancelToken in _activeDownloads.values) {
      cancelToken.cancel('Cache został wyczyszczony');
    }
    _activeDownloads.clear();

    // Usuń wszystkie pliki fizyczne
    final cachedFiles = await _database.getAllCachedFiles();
    for (final file in cachedFiles) {
      if (file.localPath != null) {
        try {
          final physicalFile = File(file.localPath!);
          if (await physicalFile.exists()) {
            await physicalFile.delete();
          }
        } catch (e) {
          // Ignoruj błędy usuwania plików
        }
      }
    }

    // Wyczyść bazę danych
    await _database.clearAllData();
  }

  // =============== PROGRESS TRACKING ===============

  /// Stream postępu pobierania dla danego pliku
  Stream<DownloadProgress>? downloadProgress(int fileId) {
    return _progressControllers[fileId]?.stream;
  }

  /// Sprawdza czy plik jest w trakcie pobierania
  bool isDownloading(int fileId) {
    return _activeDownloads.containsKey(fileId);
  }

  // =============== UTILITY METHODS ===============

  /// Pobiera katalog cache aplikacji
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'audio_cache'));
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir;
  }

  /// Oblicza sumę kontrolną pliku
  Future<String> _calculateChecksum(File file) async {
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Pobiera statystyki cache
  Future<Map<String, dynamic>> getCacheStats() async {
    final dbStats = await _database.getCacheStats();
    final availableSpace = await getAvailableSpace();
    
    return {
      ...dbStats,
      'availableSpace': availableSpace,
      'maxCacheSize': _config.maxCacheSize,
      'activeDownloads': activeDownloadCount,
      'needsCleanup': await needsCleanup(),
    };
  }

  /// Sprawdza integralność cache'owanych plików
  Future<List<int>> verifyCache() async {
    final cachedFiles = await _database.getAllCachedFiles();
    final corruptedFiles = <int>[];

    for (final file in cachedFiles) {
      if (file.localPath != null) {
        final physicalFile = File(file.localPath!);
        
        if (!await physicalFile.exists()) {
          corruptedFiles.add(file.fileId);
          await _database.updateFileStatus(file.fileId, CacheStatus.notCached);
        } else if (file.checksum != null) {
          final currentChecksum = await _calculateChecksum(physicalFile);
          if (currentChecksum != file.checksum) {
            corruptedFiles.add(file.fileId);
            await deleteFile(file.fileId);
          }
        }
      }
    }

    return corruptedFiles;
  }

  /// Zamyka serwis i czyści zasoby
  Future<void> dispose() async {
    // Anuluj wszystkie aktywne pobierania
    for (final cancelToken in _activeDownloads.values) {
      cancelToken.cancel('Serwis zostaje zamknięty');
    }
    _activeDownloads.clear();

    // Zamknij wszystkie kontrolery
    for (final controller in _progressControllers.values) {
      await controller.close();
    }
    _progressControllers.clear();

    // Zamknij bazę danych
    await _database.close();
  }
}