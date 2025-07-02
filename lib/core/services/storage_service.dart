import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/core/models/session.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/services/session_storage_service.dart';
import 'package:bandspace_mobile/core/services/cache_storage_service.dart';
import 'package:bandspace_mobile/core/services/connectivity_storage_service.dart';

/// Klucze używane do przechowywania danych w lokalnym magazynie
/// 
/// UWAGA: Ta klasa zostanie usunięta w przyszłości.
/// Należy używać kluczy z wyspecjalizowanych serwisów:
/// - SessionStorageKeys dla sesji
/// - CacheStorageKeys dla cache
/// - ConnectivityStorageKeys dla connectivity
@Deprecated('Użyj kluczy z wyspecjalizowanych serwisów')
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
  
  // Connectivity timestamps
  static const String lastOnlineTime = 'last_online_time';
  
  // Songs cache (per project)
  static String songsCacheKey(int projectId) => 'songs_cache_$projectId';
  static String songsTimestampKey(int projectId) => 'songs_timestamp_$projectId';
}

/// Serwis odpowiedzialny za zarządzanie lokalnym przechowywaniem danych.
///
/// UWAGA: Ta klasa została zrefaktoryzowana do Facade Pattern.
/// Deleguje operacje do wyspecjalizowanych serwisów:
/// - SessionStorageService - zarządzanie sesjami
/// - CacheStorageService - cache'owanie danych
/// - ConnectivityStorageService - dane połączenia internetowego
///
/// Zachowana została pełna backward compatibility.
class StorageService {
  final FlutterSecureStorage _storage;
  final SessionStorageService _sessionStorage;
  final CacheStorageService _cacheStorage;
  final ConnectivityStorageService _connectivityStorage;

  /// Singleton instance
  static final StorageService _instance = StorageService._internal();

  /// Fabryka zwracająca singleton
  factory StorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący składowe serwisy
  StorageService._internal() 
      : _storage = const FlutterSecureStorage(),
        _sessionStorage = SessionStorageService(),
        _cacheStorage = CacheStorageService(),
        _connectivityStorage = ConnectivityStorageService();

  // =============== SESSION METHODS (delegated to SessionStorageService) ===============

  /// Zapisuje token dostępu
  Future<void> saveAccessToken(String token) async {
    return await _sessionStorage.saveAccessToken(token);
  }

  /// Odczytuje token dostępu
  Future<String?> getAccessToken() async {
    return await _sessionStorage.getAccessToken();
  }

  /// Zapisuje token odświeżania
  Future<void> saveRefreshToken(String? token) async {
    return await _sessionStorage.saveRefreshToken(token);
  }

  /// Odczytuje token odświeżania
  Future<String?> getRefreshToken() async {
    return await _sessionStorage.getRefreshToken();
  }

  /// Zapisuje dane użytkownika
  Future<void> saveUser(User user) async {
    return await _sessionStorage.saveUser(user);
  }

  /// Odczytuje dane użytkownika
  Future<User?> getUser() async {
    return await _sessionStorage.getUser();
  }

  /// Zapisuje dane sesji
  Future<void> saveSession(Session session) async {
    return await _sessionStorage.saveSession(session);
  }

  /// Odczytuje dane sesji
  Future<Session?> getSession() async {
    return await _sessionStorage.getSession();
  }

  /// Sprawdza, czy użytkownik jest zalogowany
  Future<bool> isLoggedIn() async {
    return await _sessionStorage.isLoggedIn();
  }

  /// Usuwa wszystkie dane sesji
  Future<void> clearSession() async {
    return await _sessionStorage.clearSession();
  }

  /// Usuwa wszystkie dane z magazynu
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // =============== CACHE METHODS (delegated to CacheStorageService) ===============

  /// Cache configuration
  static const Duration defaultCacheTtl = Duration(hours: 24);

  /// Zapisuje listę projektów w cache
  Future<void> cacheProjects(List<Project> projects) async {
    return await _cacheStorage.cacheProjects(projects);
  }

  /// Odczytuje projekty z cache
  Future<List<Project>?> getCachedProjects() async {
    return await _cacheStorage.getCachedProjects();
  }

  /// Usuwa cache projektów
  Future<void> clearProjectsCache() async {
    return await _cacheStorage.clearProjectsCache();
  }

  /// Zapisuje utwory dla konkretnego projektu
  Future<void> cacheSongs(int projectId, List<Song> songs) async {
    return await _cacheStorage.cacheSongs(projectId, songs);
  }

  /// Odczytuje utwory dla konkretnego projektu
  Future<List<Song>?> getCachedSongs(int projectId) async {
    return await _cacheStorage.getCachedSongs(projectId);
  }

  /// Usuwa cache utworów dla konkretnego projektu
  Future<void> clearSongsCache(int projectId) async {
    return await _cacheStorage.clearSongsCache(projectId);
  }

  /// Sprawdza czy cache wygasł
  Future<bool> isCacheExpired(String timestampKey, {Duration? ttl}) async {
    return await _cacheStorage.isCacheExpired(timestampKey, ttl: ttl);
  }

  /// Sprawdza czy cache projektów wygasł
  Future<bool> isProjectsCacheExpired({Duration? ttl}) async {
    return await _cacheStorage.isProjectsCacheExpired(ttl: ttl);
  }

  /// Sprawdza czy cache utworów wygasł
  Future<bool> isSongsCacheExpired(int projectId, {Duration? ttl}) async {
    return await _cacheStorage.isSongsCacheExpired(projectId, ttl: ttl);
  }

  /// Odczytuje wiek cache'a (w minutach)
  Future<int?> getCacheAgeInMinutes(String timestampKey) async {
    return await _cacheStorage.getCacheAgeInMinutes(timestampKey);
  }

  /// Usuwa wszystkie cache offline
  Future<void> clearAllOfflineCache() async {
    return await _cacheStorage.clearAllCache();
  }

  // =============== CONNECTIVITY METHODS (delegated to ConnectivityStorageService) ===============

  /// Zapisuje czas ostatniego połączenia online
  Future<void> saveLastOnlineTime(DateTime timestamp) async {
    return await _connectivityStorage.saveLastOnlineTime(timestamp);
  }

  /// Odczytuje czas ostatniego połączenia online
  Future<DateTime?> getLastOnlineTime() async {
    return await _connectivityStorage.getLastOnlineTime();
  }
}
