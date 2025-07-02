import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/core/models/session.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';

/// Klucze używane do przechowywania danych w lokalnym magazynie
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user';
  static const String session = 'session';
  
  // Offline cache keys
  static const String cachedProjects = 'cached_projects';
  static const String projectsTimestamp = 'projects_timestamp';
  
  // Cache timestamps
  static const String cachePrefix = 'cache_';
  static const String timestampSuffix = '_timestamp';
  
  // Songs cache (per project)
  static String songsCacheKey(int projectId) => 'songs_cache_$projectId';
  static String songsTimestampKey(int projectId) => 'songs_timestamp_$projectId';
}

/// Serwis odpowiedzialny za zarządzanie lokalnym przechowywaniem danych.
///
/// Używa flutter_secure_storage do bezpiecznego przechowywania wrażliwych danych,
/// takich jak tokeny dostępu i dane użytkownika.
class StorageService {
  final FlutterSecureStorage _storage;

  /// Singleton instance
  static final StorageService _instance = StorageService._internal();

  /// Fabryka zwracająca singleton
  factory StorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący FlutterSecureStorage
  StorageService._internal() : _storage = const FlutterSecureStorage();

  /// Zapisuje token dostępu
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Odczytuje token dostępu
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Zapisuje token odświeżania
  Future<void> saveRefreshToken(String? token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  /// Odczytuje token odświeżania
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Zapisuje dane użytkownika
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toMap());
    await _storage.write(key: StorageKeys.user, value: userJson);
  }

  /// Odczytuje dane użytkownika
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: StorageKeys.user);
    if (userJson == null) return null;

    try {
      return User.fromMap(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// Zapisuje dane sesji
  Future<void> saveSession(Session session) async {
    final sessionJson = jsonEncode(session.toMap());
    await _storage.write(key: StorageKeys.session, value: sessionJson);

    // Zapisz również tokeny i dane użytkownika osobno dla łatwiejszego dostępu
    await saveAccessToken(session.accessToken);
    await saveRefreshToken(session.refreshToken);
    await saveUser(session.user);
  }

  /// Odczytuje dane sesji
  Future<Session?> getSession() async {
    final sessionJson = await _storage.read(key: StorageKeys.session);
    if (sessionJson == null) return null;

    try {
      return Session.fromMap(jsonDecode(sessionJson));
    } catch (e) {
      return null;
    }
  }

  /// Sprawdza, czy użytkownik jest zalogowany
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final user = await getUser();

    return accessToken != null && user != null;
  }

  /// Usuwa wszystkie dane sesji
  Future<void> clearSession() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.user);
    await _storage.delete(key: StorageKeys.session);
  }

  /// Usuwa wszystkie dane z magazynu
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // =============== OFFLINE CACHE METHODS ===============

  /// Cache configuration
  static const Duration defaultCacheTtl = Duration(hours: 24);

  /// Zapisuje listę projektów w cache
  Future<void> cacheProjects(List<Project> projects) async {
    final projectsJson = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _storage.write(key: StorageKeys.cachedProjects, value: projectsJson);
    await _setCacheTimestamp(StorageKeys.projectsTimestamp);
  }

  /// Odczytuje projekty z cache
  Future<List<Project>?> getCachedProjects() async {
    final projectsJson = await _storage.read(key: StorageKeys.cachedProjects);
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
    await _storage.delete(key: StorageKeys.cachedProjects);
    await _storage.delete(key: StorageKeys.projectsTimestamp);
  }

  /// Zapisuje utwory dla konkretnego projektu
  Future<void> cacheSongs(int projectId, List<Song> songs) async {
    final songsJson = jsonEncode(songs.map((s) => s.toJson()).toList());
    final cacheKey = StorageKeys.songsCacheKey(projectId);
    final timestampKey = StorageKeys.songsTimestampKey(projectId);
    
    await _storage.write(key: cacheKey, value: songsJson);
    await _setCacheTimestamp(timestampKey);
  }

  /// Odczytuje utwory dla konkretnego projektu
  Future<List<Song>?> getCachedSongs(int projectId) async {
    final cacheKey = StorageKeys.songsCacheKey(projectId);
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
    final cacheKey = StorageKeys.songsCacheKey(projectId);
    final timestampKey = StorageKeys.songsTimestampKey(projectId);
    
    await _storage.delete(key: cacheKey);
    await _storage.delete(key: timestampKey);
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

  /// Sprawdza czy cache projektów wygasł
  Future<bool> isProjectsCacheExpired({Duration? ttl}) async {
    return await isCacheExpired(StorageKeys.projectsTimestamp, ttl: ttl);
  }

  /// Sprawdza czy cache utworów wygasł
  Future<bool> isSongsCacheExpired(int projectId, {Duration? ttl}) async {
    final timestampKey = StorageKeys.songsTimestampKey(projectId);
    return await isCacheExpired(timestampKey, ttl: ttl);
  }

  /// Odczytuje wiek cache'a (w minutach)
  Future<int?> getCacheAgeInMinutes(String timestampKey) async {
    final timestamp = await _getCacheTimestamp(timestampKey);
    if (timestamp == null) return null;

    final difference = DateTime.now().difference(timestamp);
    return difference.inMinutes;
  }

  /// Usuwa wszystkie cache offline
  Future<void> clearAllOfflineCache() async {
    // Clear projects cache
    await clearProjectsCache();
    
    // Clear all songs cache (we'd need to track project IDs, but for now clear all cache keys)
    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith('songs_cache_') || key.startsWith('songs_timestamp_')) {
        await _storage.delete(key: key);
      }
    }
  }
}
