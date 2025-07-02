import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/cubit/connectivity_cubit.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/services/storage_service.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_state.dart';

/// Cubit zarządzający stanem ekranu dashboardu
class DashboardCubit extends Cubit<DashboardState> {
  final ProjectRepository projectRepository;
  final StorageService _storageService;
  final ConnectivityCubit _connectivityCubit;

  /// Kontroler dla pola nazwy projektu
  final TextEditingController nameController = TextEditingController();

  /// Kontroler dla pola opisu projektu
  final TextEditingController descriptionController = TextEditingController();

  DashboardCubit({
    required this.projectRepository,
    StorageService? storageService,
    required ConnectivityCubit connectivityCubit,
  }) : _storageService = storageService ?? StorageService(),
       _connectivityCubit = connectivityCubit,
       super(const DashboardState());

  @override
  Future<void> close() {
    nameController.dispose();
    descriptionController.dispose();
    return super.close();
  }

  /// Pobiera listę projektów użytkownika (strategia offline-first)
  Future<void> loadProjects() async {
    // Jeśli już trwa ładowanie, nie rób nic
    if (state.status == DashboardStatus.loading) return;

    // Ustaw stan ładowania
    emit(state.copyWith(status: DashboardStatus.loading, errorMessage: null));

    try {
      // 1. ZAWSZE NAJPIERW SPRAWDŹ CACHE
      await _loadCachedProjects();

      // 2. JEŚLI ONLINE - SPRAWDŹ CZY CACHE JEST AKTUALNY
      final isOnline = _connectivityCubit.state.isOnline;

      if (isOnline) {
        final cacheExpired = await _storageService.isProjectsCacheExpired();

        if (cacheExpired || state.projects.isEmpty) {
          // Cache wygasł lub brak danych - pobierz z serwera
          await _syncWithServer();
        } else {
          // Cache aktualny - ustaw jako loaded, ale nie offline
          emit(state.copyWith(status: DashboardStatus.loaded, isOfflineMode: false, lastSyncTime: DateTime.now()));
        }
      } else {
        // OFFLINE - użyj tylko cache
        if (state.projects.isNotEmpty) {
          emit(state.copyWith(status: DashboardStatus.loaded, isOfflineMode: true));
        } else {
          emit(
            state.copyWith(
              status: DashboardStatus.error,
              isOfflineMode: true,
              errorMessage: 'Brak połączenia internetowego i brak danych offline',
            ),
          );
        }
      }
    } catch (e) {
      // Jeśli mamy cache, pokaż go z błędem
      if (state.projects.isNotEmpty) {
        emit(
          state.copyWith(
            status: DashboardStatus.loaded,
            isOfflineMode: true,
            errorMessage: 'Błąd synchronizacji - używam danych offline',
          ),
        );
      } else {
        emit(state.copyWith(status: DashboardStatus.error, errorMessage: 'Wystąpił błąd: $e'));
      }
    }
  }

  /// Ładuje projekty z lokalnego cache
  Future<void> _loadCachedProjects() async {
    final cachedProjects = await _storageService.getCachedProjects();
    if (cachedProjects != null && cachedProjects.isNotEmpty) {
      emit(
        state.copyWith(
          projects: cachedProjects,
          status: DashboardStatus.loaded,
          isOfflineMode: true, // Tymczasowo offline, może się zmieni
        ),
      );
    }
  }

  /// Synchronizuje dane z serwerem i cache'uje
  Future<void> _syncWithServer() async {
    emit(state.copyWith(isSyncing: true));

    try {
      // Pobierz z API
      final projects = await projectRepository.getProjects();

      // Zapisz w cache
      await _storageService.cacheProjects(projects);

      // Aktualizuj stan
      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          projects: projects,
          isOfflineMode: false,
          lastSyncTime: DateTime.now(),
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

  /// Tworzy nowy projekt
  Future<void> createProject() async {
    // Sprawdź, czy nazwa projektu nie jest pusta
    if (nameController.text.isEmpty) {
      emit(state.copyWith(errorMessage: 'Nazwa projektu nie może być pusta'));
      return;
    }

    // Ustaw stan tworzenia projektu
    emit(state.copyWith(isCreatingProject: true, errorMessage: null));

    try {
      // Utwórz projekt w repozytorium
      await projectRepository.createProject(
        name: nameController.text.trim(),
        description: descriptionController.text.isNotEmpty ? descriptionController.text.trim() : null,
      );

      // Wyczyść pola formularza
      nameController.clear();
      descriptionController.clear();

      // Ustaw stan tworzenia projektu na false
      emit(state.copyWith(isCreatingProject: false));

      // Załaduj projekty ponownie, aby uwzględnić nowy projekt
      await loadProjects();
    } on ApiException catch (e) {
      // Obsługa błędów API
      emit(state.copyWith(isCreatingProject: false, errorMessage: 'Błąd podczas tworzenia projektu: ${e.message}'));
    } catch (e) {
      // Obsługa innych błędów
      emit(state.copyWith(isCreatingProject: false, errorMessage: 'Wystąpił nieoczekiwany błąd: $e'));
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  /// Czyści stan dashboardu (np. po wylogowaniu)
  void clearProjects() {
    emit(const DashboardState());
  }
}
