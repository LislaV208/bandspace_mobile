import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/dashboard_state.dart';
import 'package:bandspace_mobile/features/dashboard/repository/dashboard_repository.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

/// Cubit zarządzający stanem ekranu dashboardu
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository dashboardRepository;

  late StreamSubscription<List<Project>> projectsSubscription;

  DashboardCubit({
    required this.dashboardRepository,
  }) : super(const DashboardState()) {
    loadProjects();
  }

  @override
  Future<void> close() {
    projectsSubscription.cancel();
    return super.close();
  }

  Future<void> loadProjects() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    projectsSubscription = dashboardRepository.getProjects().listen((
      projects,
    ) {
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          projects: projects,
        ),
      );
    });
  }

  Future<void> refreshProjects() async {
    final projects = await dashboardRepository.getProjects().first;
    emit(
      state.copyWith(
        status: DashboardStatus.success,
        projects: projects,
      ),
    );
  }

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

      final updatedProjects = [newProject, ...state.projects];

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
