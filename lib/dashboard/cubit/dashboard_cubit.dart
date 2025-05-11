import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_state.dart';

/// Cubit zarządzający stanem ekranu dashboardu
class DashboardCubit extends Cubit<DashboardState> {
  final ProjectRepository projectRepository;

  /// Kontroler dla pola nazwy projektu
  final TextEditingController nameController = TextEditingController();

  /// Kontroler dla pola opisu projektu
  final TextEditingController descriptionController = TextEditingController();

  DashboardCubit({required this.projectRepository}) : super(const DashboardState());

  @override
  Future<void> close() {
    nameController.dispose();
    descriptionController.dispose();
    return super.close();
  }

  /// Pobiera listę projektów użytkownika
  Future<void> loadProjects() async {
    // Jeśli już trwa ładowanie, nie rób nic
    if (state.status == DashboardStatus.loading) return;

    // Ustaw stan ładowania
    emit(state.copyWith(status: DashboardStatus.loading, errorMessage: null));

    try {
      // Pobierz projekty z repozytorium
      final projects = await projectRepository.getProjects();

      // Ustaw stan załadowany z projektami
      emit(state.copyWith(status: DashboardStatus.loaded, projects: projects));
    } on ApiException catch (e) {
      // Obsługa błędów API
      emit(
        state.copyWith(status: DashboardStatus.error, errorMessage: 'Błąd podczas pobierania projektów: ${e.message}'),
      );
    } catch (e) {
      // Obsługa innych błędów
      emit(state.copyWith(status: DashboardStatus.error, errorMessage: 'Wystąpił nieoczekiwany błąd: $e'));
    }
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
}
