import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/cubit/connectivity_cubit.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/services/cache_storage_service.dart';
import 'package:bandspace_mobile/project/cubit/project_songs_state.dart';

/// Cubit zarządzający stanem utworów projektu
class ProjectSongsCubit extends Cubit<ProjectSongsState> {
  final ProjectRepository projectRepository;
  final CacheStorageService _cacheStorage;
  final ConnectivityCubit _connectivityCubit;
  final int projectId;

  ProjectSongsCubit({
    required this.projectRepository,
    required this.projectId,
    CacheStorageService? cacheStorage,
    required ConnectivityCubit connectivityCubit,
  }) : _cacheStorage = cacheStorage ?? CacheStorageService(),
       _connectivityCubit = connectivityCubit,
       super(const ProjectSongsState());

  /// Pobiera listę utworów dla projektu (offline-first strategy)
  Future<void> loadSongs() async {
    if (state.status == ProjectSongsStatus.loading) return;

    try {
      // 1. SPRAWDŹ CACHE PRZED POKAZANIEM LOADING
      final cachedSongs = await _cacheStorage.getCachedSongs(projectId);
      final hasCachedData = cachedSongs != null && cachedSongs.isNotEmpty;

      // JEŚLI MAMY CACHE - NIE POKAZUJ LOADING, OD RAZU USTAW DANE
      if (hasCachedData) {
        emit(
          state.copyWith(
            songs: cachedSongs,
            status: ProjectSongsStatus.loaded,
            isOfflineMode: true, // Tymczasowo, może się zmieni
            errorMessage: null,
          ),
        );
      } else {
        // BRAK CACHE - DOPIERO TERAZ POKAŻ LOADING
        emit(state.copyWith(status: ProjectSongsStatus.loading, errorMessage: null));
      }

      // 2. JEŚLI ONLINE - SPRAWDŹ CZY CACHE JEST AKTUALNY
      final isOnline = _connectivityCubit.state.isOnline;

      if (isOnline) {
        final cacheExpired = await _cacheStorage.isSongsCacheExpired(projectId);

        if (cacheExpired || state.songs.isEmpty) {
          // Cache wygasł lub brak danych - pobierz z serwera
          await _syncWithServer();
        } else {
          // Cache aktualny - ustaw jako loaded z trybem online
          emit(state.copyWith(status: ProjectSongsStatus.loaded, isOfflineMode: false));
        }
      } else {
        // OFFLINE - użyj tylko cache
        if (state.songs.isNotEmpty) {
          emit(state.copyWith(status: ProjectSongsStatus.loaded, isOfflineMode: true));
        } else {
          emit(
            state.copyWith(
              status: ProjectSongsStatus.error,
              isOfflineMode: true,
              errorMessage: 'Brak połączenia internetowego i brak danych offline',
            ),
          );
        }
      }
    } catch (e) {
      // Jeśli mamy cache, pokaż go z błędem
      if (state.songs.isNotEmpty) {
        emit(
          state.copyWith(
            status: ProjectSongsStatus.loaded,
            isOfflineMode: true,
            errorMessage: 'Błąd synchronizacji - używam danych offline',
          ),
        );
      } else {
        emit(state.copyWith(status: ProjectSongsStatus.error, errorMessage: 'Wystąpił błąd: $e'));
      }
    }
  }

  /// Synchronizuje dane z serwerem i cache'uje
  Future<void> _syncWithServer() async {
    emit(state.copyWith(isSyncing: true));

    try {
      // Pobierz z API
      final songs = await projectRepository.getProjectSongs(projectId);

      // Zapisz w cache
      await _cacheStorage.cacheSongs(projectId, songs);

      // Aktualizuj stan
      emit(
        state.copyWith(
          status: ProjectSongsStatus.loaded,
          songs: songs,
          isOfflineMode: false,
          isSyncing: false,
          errorMessage: null,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isSyncing: false, errorMessage: 'Błąd API: ${e.message}', isOfflineMode: true));
      rethrow;
    } catch (e) {
      emit(state.copyWith(isSyncing: false, errorMessage: 'Błąd synchronizacji: $e', isOfflineMode: true));
      rethrow;
    }
  }

  /// Manualny sync (pull-to-refresh)
  Future<void> syncWithServer() async {
    if (!_connectivityCubit.state.isOnline) {
      emit(state.copyWith(errorMessage: 'Brak połączenia internetowego'));
      return;
    }

    await _syncWithServer();
  }

  /// Tworzy nowy utwór
  Future<void> createSong(String title) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Tytuł utworu nie może być pusty'));
      return;
    }

    emit(state.copyWith(isCreatingSong: true, errorMessage: null));

    try {
      final newSong = await projectRepository.createSong(projectId: projectId, title: title.trim());

      final updatedSongs = [newSong, ...state.songs];
      emit(state.copyWith(isCreatingSong: false, songs: updatedSongs));
    } on ApiException catch (e) {
      emit(state.copyWith(isCreatingSong: false, errorMessage: 'Błąd podczas tworzenia utworu: ${e.message}'));
    } catch (e) {
      emit(state.copyWith(isCreatingSong: false, errorMessage: 'Wystąpił nieoczekiwany błąd: $e'));
    }
  }

  /// Usuwa utwór
  Future<void> deleteSong(Song song) async {
    emit(state.copyWith(isDeletingSong: true, errorMessage: null));

    try {
      await projectRepository.deleteSong(projectId: projectId, songId: song.id);

      final updatedSongs = state.songs.where((s) => s.id != song.id).toList();
      emit(state.copyWith(isDeletingSong: false, songs: updatedSongs));
    } on ApiException catch (e) {
      emit(state.copyWith(isDeletingSong: false, errorMessage: 'Błąd podczas usuwania utworu: ${e.message}'));
    } catch (e) {
      emit(state.copyWith(isDeletingSong: false, errorMessage: 'Wystąpił nieoczekiwany błąd: $e'));
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  /// Filtruje utwory na podstawie zapytania
  List<Song> getFilteredSongs(String query) {
    if (query.trim().isEmpty) {
      return state.songs;
    }

    final lowerQuery = query.toLowerCase();
    return state.songs.where((song) => song.title.toLowerCase().contains(lowerQuery)).toList();
  }
}
