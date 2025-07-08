import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

/// Enum reprezentujący status ładowania danych
enum DashboardStatus {
  initial,
  loading,
  success,
  error,
  creatingProject,
}

/// Stan dla ekranu dashboardu
class DashboardState extends Equatable {
  /// Status ładowania danych
  final DashboardStatus status;

  /// Lista projektów użytkownika
  final List<Project> projects;

  /// Komunikat błędu, jeśli wystąpił
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.projects = const [],
    this.errorMessage,
  });

  /// Tworzy kopię stanu z nowymi wartościami
  DashboardState copyWith({
    DashboardStatus? status,
    List<Project>? projects,
    Value<String?>? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    projects,
    errorMessage,
  ];
}
