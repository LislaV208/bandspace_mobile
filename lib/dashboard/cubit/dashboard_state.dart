import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/models/project.dart';

/// Enum reprezentujący status ładowania danych
enum DashboardStatus {
  /// Początkowy stan, przed rozpoczęciem ładowania
  initial,

  /// Dane są w trakcie ładowania
  loading,

  /// Dane zostały pomyślnie załadowane
  loaded,

  /// Wystąpił błąd podczas ładowania danych
  error,
}

/// Stan dla ekranu dashboardu
class DashboardState extends Equatable {
  /// Status ładowania danych
  final DashboardStatus status;

  /// Lista projektów użytkownika
  final List<Project> projects;

  /// Komunikat błędu, jeśli wystąpił
  final String? errorMessage;

  /// Flaga wskazująca, czy trwa tworzenie nowego projektu
  final bool isCreatingProject;

  /// Czy aplikacja jest w trybie offline
  final bool isOfflineMode;

  /// Czas ostatniej synchronizacji z serwerem
  final DateTime? lastSyncTime;

  /// Czy trwa synchronizacja
  final bool isSyncing;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.projects = const [],
    this.errorMessage,
    this.isCreatingProject = false,
    this.isOfflineMode = false,
    this.lastSyncTime,
    this.isSyncing = false,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  DashboardState copyWith({
    DashboardStatus? status,
    List<Project>? projects,
    String? errorMessage,
    bool? isCreatingProject,
    bool? isOfflineMode,
    DateTime? lastSyncTime,
    bool? isSyncing,
  }) {
    return DashboardState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage,
      isCreatingProject: isCreatingProject ?? this.isCreatingProject,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [status, projects, errorMessage, isCreatingProject, isOfflineMode, lastSyncTime, isSyncing];
}
