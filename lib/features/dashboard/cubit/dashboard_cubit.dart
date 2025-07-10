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

    projectsSubscription =
        dashboardRepository.getProjects().listen((
          projects,
        ) async {
          if (state.status == DashboardStatus.creatingProject) {
            // poczekaj z aktualizacją listy projektów
            // dla lepszego UX
            await Future.delayed(const Duration(milliseconds: 200));
          }

          emit(
            state.copyWith(
              status: DashboardStatus.success,
              projects: projects,
            ),
          );
        })..onError(
          (error, stackTrace) {
            emit(
              state.copyWith(
                status: DashboardStatus.error,
                errorMessage: Value(error.toString()),
              ),
            );
          },
        );
  }

  Future<void> refreshProjects({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: DashboardStatus.loading));
    }

    final projects = await dashboardRepository
        .getProjects(forceRefresh: true)
        .first;
    emit(
      state.copyWith(
        status: DashboardStatus.success,
        projects: projects,
      ),
    );
  }

  Future<Project?> createProject(String name) async {
    emit(
      state.copyWith(
        status: DashboardStatus.creatingProject,
        errorMessage: null,
      ),
    );

    try {
      return dashboardRepository.createProject(name: name.trim());
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
    }
    return null;
  }
}
