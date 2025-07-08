import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/dashboard_state.dart';
import 'package:bandspace_mobile/features/dashboard/repository/dashboard_repository.dart';

/// Cubit zarządzający stanem ekranu dashboardu
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardCubit({
    required this.dashboardRepository,
  }) : super(const DashboardState()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final projects = await dashboardRepository.getProjects();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          projects: projects,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          projects: [],
          status: DashboardStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
    }
  }

  /// Tworzy nowy projekt
  Future<void> createProject(String name) async {
    name = name.trim();

    if (name.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: Value(
            'Nazwa projektu nie może być pusta',
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DashboardStatus.creatingProject,
        errorMessage: null,
      ),
    );

    try {
      final newProject = await dashboardRepository.createProject(
        name: name.trim(),
      );

      final updatedProjects = [
        newProject,
        ...state.projects,
      ];
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          projects: updatedProjects,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
    }
  }
}
