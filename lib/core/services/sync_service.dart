import 'dart:async';

import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/repositories/song_repository.dart';
import 'package:bandspace_mobile/core/services/cache_storage_service.dart';
import 'package:bandspace_mobile/core/services/connectivity_service.dart';

/// Model rezultatu synchronizacji
class SyncResult {
  final bool success;
  final String? error;
  final DateTime syncTime;
  final Map<String, dynamic> details;

  const SyncResult({
    required this.success,
    this.error,
    required this.syncTime,
    this.details = const {},
  });

  SyncResult.success({Map<String, dynamic>? details})
      : success = true,
        error = null,
        syncTime = DateTime.now(),
        details = details ?? {};

  SyncResult.failure(this.error, {Map<String, dynamic>? details})
      : success = false,
        syncTime = DateTime.now(),
        details = details ?? {};
}

/// Status synchronizacji
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// Serwis zarządzający synchronizacją danych offline/online
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._internal();
  
  SyncService._internal();

  final ProjectRepository _projectRepository = ProjectRepository();
  final SongRepository _songRepository = SongRepository();
  final CacheStorageService _cacheStorage = CacheStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Stream controllers dla sync status
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  final StreamController<SyncResult> _syncResultController = StreamController<SyncResult>.broadcast();

  // Getters dla streams
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<SyncResult> get syncResultStream => _syncResultController.stream;

  // Current sync status
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  // Last sync result
  SyncResult? _lastSyncResult;
  SyncResult? get lastSyncResult => _lastSyncResult;

  /// Pełna synchronizacja danych użytkownika
  Future<SyncResult> syncUserData() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult.failure('Synchronizacja już w toku');
    }

    // Sprawdź połączenie internetowe
    if (!_connectivityService.isOnline) {
      return SyncResult.failure('Brak połączenia z internetem');
    }

    _updateSyncStatus(SyncStatus.syncing);

    try {
      
      final Map<String, dynamic> syncDetails = {};
      
      // 1. Synchronizuj projekty
      final projectsResult = await syncProjects();
      syncDetails['projects'] = {
        'success': projectsResult.success,
        'count': projectsResult.details['count'] ?? 0,
        'error': projectsResult.error,
      };

      if (!projectsResult.success) {
        _updateSyncStatus(SyncStatus.error);
        final result = SyncResult.failure(
          'Błąd synchronizacji projektów: ${projectsResult.error}',
          details: syncDetails,
        );
        _lastSyncResult = result;
        _syncResultController.add(result);
        return result;
      }

      // 2. Synchronizuj utwory dla każdego projektu
      final cachedProjects = await _cacheStorage.getCachedProjects();
      if (cachedProjects != null) {
        int totalSongs = 0;
        for (final project in cachedProjects) {
          final songsResult = await syncProject(project.id);
          totalSongs += songsResult.details['count'] as int? ?? 0;
          
          if (!songsResult.success) {
            // Kontynuuj z innymi projektami mimo błędu
          }
        }
        syncDetails['songs'] = {
          'totalCount': totalSongs,
          'projectsCount': cachedProjects.length,
        };
      }

      _updateSyncStatus(SyncStatus.success);
      final result = SyncResult.success(details: syncDetails);
      _lastSyncResult = result;
      _syncResultController.add(result);
      
      return result;

    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      final result = SyncResult.failure('Nieoczekiwany błąd synchronizacji: $e');
      _lastSyncResult = result;
      _syncResultController.add(result);
      return result;
    }
  }

  /// Synchronizacja projektów
  Future<SyncResult> syncProjects() async {
    try {
      
      // Pobierz projekty z API
      final projects = await _projectRepository.getProjects();
      
      // Cache projektów
      await _cacheStorage.cacheProjects(projects);
      
      return SyncResult.success(details: {'count': projects.length});
      
    } catch (e) {
      return SyncResult.failure('Błąd synchronizacji projektów: $e');
    }
  }

  /// Synchronizacja pojedynczego projektu (utwory)
  Future<SyncResult> syncProject(int projectId) async {
    try {
      
      // Pobierz utwory projektu z API
      final songs = await _projectRepository.getProjectSongs(projectId);
      
      // Cache utworów
      await _cacheStorage.cacheSongs(projectId, songs);
      
      return SyncResult.success(details: {'count': songs.length});
      
    } catch (e) {
      return SyncResult.failure('Błąd synchronizacji projektu $projectId: $e');
    }
  }

  /// Synchronizacja plików pojedynczego utworu
  Future<SyncResult> syncSongFiles(int songId) async {
    try {
      // Pobierz pliki utworu z API
      final files = await _songRepository.getSongFiles(songId);
      
      // Cache plików
      await _cacheStorage.cacheSongFiles(songId, files);
      
      return SyncResult.success(details: {'count': files.length});
      
    } catch (e) {
      return SyncResult.failure('Błąd synchronizacji plików utworu $songId: $e');
    }
  }

  /// Synchronizacja szczegółów pojedynczego utworu
  Future<SyncResult> syncSongDetail(int projectId, int songId) async {
    try {
      // Pobierz szczegóły utworu z API
      final songDetail = await _songRepository.getSongDetails(projectId: projectId, songId: songId);
      
      // Cache szczegółów
      await _cacheStorage.cacheSongDetail(songId, songDetail);
      
      return SyncResult.success(details: {'songId': songId});
      
    } catch (e) {
      return SyncResult.failure('Błąd synchronizacji szczegółów utworu $songId: $e');
    }
  }

  /// Inteligentny sync - cache tylko dla odwiedzanych ekranów
  Future<SyncResult> smartSync() async {
    try {
      final Map<String, dynamic> syncDetails = {};
      
      // 1. Sync wszystkich projektów (zawsze)
      final projectsResult = await syncProjects();
      syncDetails['projects'] = projectsResult.details;
      
      if (!projectsResult.success) {
        return SyncResult.failure('Błąd sync projektów: ${projectsResult.error}', details: syncDetails);
      }

      // 2. Sync songs tylko dla projektów które są już w cache 
      //    (oznacza że użytkownik je odwiedził)
      final cachedProjects = await _cacheStorage.getCachedProjects();
      if (cachedProjects != null) {
        int totalSongs = 0;
        for (final project in cachedProjects) {
          // Sprawdź czy project ma już cached songs (był odwiedzony)
          final existingSongs = await _cacheStorage.getCachedSongs(project.id);
          if (existingSongs != null) {
            final songsResult = await syncProject(project.id);
            totalSongs += songsResult.details['count'] as int? ?? 0;
          }
        }
        syncDetails['songs'] = {'totalCount': totalSongs};
      }

      return SyncResult.success(details: syncDetails);
      
    } catch (e) {
      return SyncResult.failure('Błąd smart sync: $e');
    }
  }

  /// Sprawdź czy potrzebna jest synchronizacja
  Future<bool> needsSync() async {
    // Sprawdź czy cache wygasł
    final projectsExpired = await _cacheStorage.isProjectsCacheExpired();
    if (projectsExpired) return true;

    // Sprawdź czy mamy cached projekty
    final cachedProjects = await _cacheStorage.getCachedProjects();
    if (cachedProjects == null || cachedProjects.isEmpty) return true;

    // Sprawdź czy utwory wygasły dla jakiegokolwiek projektu
    for (final project in cachedProjects) {
      final songsExpired = await _cacheStorage.isSongsCacheExpired(project.id);
      if (songsExpired) return true;
    }

    return false;
  }

  /// Synchronizacja w tle po powrocie połączenia
  Future<void> syncOnConnectionRestore() async {
    if (await needsSync()) {
      syncUserData(); // Fire-and-forget
    }
  }

  /// Synchronizacja przy starcie aplikacji
  Future<void> syncOnAppLaunch() async {
    // Sprawdź połączenie
    if (!_connectivityService.isOnline) {
      return;
    }

    // Sprawdź czy potrzebna synchronizacja
    if (await needsSync()) {
      syncUserData(); // Fire-and-forget
    }
  }

  /// Aktualizuje status synchronizacji
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Pobierz ostatni czas synchronizacji
  Future<DateTime?> getLastSyncTime() async {
    return _lastSyncResult?.syncTime;
  }

  /// Sprawdź czy synchronizacja jest w toku
  bool get isSyncing => _currentStatus == SyncStatus.syncing;

  /// Wyczyść historię synchronizacji
  void clearSyncHistory() {
    _lastSyncResult = null;
    _updateSyncStatus(SyncStatus.idle);
  }

  /// Cleanup resources
  void dispose() {
    _syncStatusController.close();
    _syncResultController.close();
  }
}