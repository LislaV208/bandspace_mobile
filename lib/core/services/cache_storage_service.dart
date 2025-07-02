import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';

/// Klucze używane do przechowywania danych cache
class CacheStorageKeys {
  // Projects cache
  static const String cachedProjects = 'cached_projects';
  static const String projectsTimestamp = 'projects_timestamp';
  
  // Cache timestamps
  static const String cachePrefix = 'cache_';
  static const String timestampSuffix = '_timestamp';
  
  // Songs cache (per project)
  static String songsCacheKey(int projectId) => 'songs_cache_$projectId';
  static String songsTimestampKey(int projectId) => 'songs_timestamp_$projectId';
}

/// Serwis odpowiedzialny za cache'owanie danych aplikacji.
///
/// Zarządza cache'owaniem projektów, utworów i metadanych
/// z automatycznym zarządzaniem czasem życia (TTL).
class CacheStorageService {
  final FlutterSecureStorage _storage;

  /// Singleton instance
  static final CacheStorageService _instance = CacheStorageService._internal();

  /// Factory zwracająca singleton
  factory CacheStorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący FlutterSecureStorage
  CacheStorageService._internal() : _storage = const FlutterSecureStorage();

  /// Cache configuration
  static const Duration defaultCacheTtl = Duration(hours: 24);

  // =============== PROJECTS CACHE ===============

  /// Zapisuje listę projektów w cache
  Future<void> cacheProjects(List<Project> projects) async {
    final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _storage.write(key: CacheStorageKeys.cachedProjects, value: projectsJson);
    await _setCacheTimestamp(CacheStorageKeys.projectsTimestamp);
  }

  /// Odczytuje projekty z cache
  Future<List<Project>?> getCachedProjects() async {
    final projectsJson = await _storage.read(key: CacheStorageKeys.cachedProjects);
    if (projectsJson == null) return null;

    try {
      final List<dynamic> projectsList = jsonDecode(projectsJson);
      return projectsList.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Usuwa cache projektów
  Future<void> clearProjectsCache() async {
    await _storage.delete(key: CacheStorageKeys.cachedProjects);
    await _storage.delete(key: CacheStorageKeys.projectsTimestamp);
  }

  /// Sprawdza czy cache projektów wygasł
  Future<bool> isProjectsCacheExpired({Duration? ttl}) async {
    return await isCacheExpired(CacheStorageKeys.projectsTimestamp, ttl: ttl);
  }

  // =============== SONGS CACHE ===============

  /// Zapisuje utwory dla konkretnego projektu
  Future<void> cacheSongs(int projectId, List<Song> songs) async {
    final songsJson = jsonEncode(songs.map((s) => s.toJson()).toList());
    final cacheKey = CacheStorageKeys.songsCacheKey(projectId);
    final timestampKey = CacheStorageKeys.songsTimestampKey(projectId);
    
    await _storage.write(key: cacheKey, value: songsJson);
    await _setCacheTimestamp(timestampKey);
  }

  /// Odczytuje utwory dla konkretnego projektu
  Future<List<Song>?> getCachedSongs(int projectId) async {
    final cacheKey = CacheStorageKeys.songsCacheKey(projectId);
    final songsJson = await _storage.read(key: cacheKey);
    if (songsJson == null) return null;

    try {
      final List<dynamic> songsList = jsonDecode(songsJson);
      return songsList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Usuwa cache utworów dla konkretnego projektu
  Future<void> clearSongsCache(int projectId) async {
    final cacheKey = CacheStorageKeys.songsCacheKey(projectId);
    final timestampKey = CacheStorageKeys.songsTimestampKey(projectId);
    
    await _storage.delete(key: cacheKey);
    await _storage.delete(key: timestampKey);
  }

  /// Sprawdza czy cache utworów wygasł
  Future<bool> isSongsCacheExpired(int projectId, {Duration? ttl}) async {
    final timestampKey = CacheStorageKeys.songsTimestampKey(projectId);
    return await isCacheExpired(timestampKey, ttl: ttl);
  }

  // =============== CACHE TIMESTAMP MANAGEMENT ===============

  /// Zapisuje timestamp cache'a
  Future<void> _setCacheTimestamp(String key) async {
    final timestamp = DateTime.now().toIso8601String();
    await _storage.write(key: key, value: timestamp);
  }

  /// Odczytuje timestamp cache'a
  Future<DateTime?> _getCacheTimestamp(String key) async {
    final timestampStr = await _storage.read(key: key);
    if (timestampStr == null) return null;

    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  /// Sprawdza czy cache wygasł
  Future<bool> isCacheExpired(String timestampKey, {Duration? ttl}) async {
    final timestamp = await _getCacheTimestamp(timestampKey);
    if (timestamp == null) return true;

    final cacheTtl = ttl ?? defaultCacheTtl;
    final expirationTime = timestamp.add(cacheTtl);
    
    return DateTime.now().isAfter(expirationTime);
  }

  /// Odczytuje wiek cache'a (w minutach)
  Future<int?> getCacheAgeInMinutes(String timestampKey) async {
    final timestamp = await _getCacheTimestamp(timestampKey);
    if (timestamp == null) return null;

    final difference = DateTime.now().difference(timestamp);
    return difference.inMinutes;
  }

  /// Usuwa wszystkie cache offline
  Future<void> clearAllCache() async {
    // Clear projects cache
    await clearProjectsCache();
    
    // Clear all songs cache (iterate through all keys)
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith('songs_cache_') || key.startsWith('songs_timestamp_')) {
        await _storage.delete(key: key);
      }
    }
  }
}