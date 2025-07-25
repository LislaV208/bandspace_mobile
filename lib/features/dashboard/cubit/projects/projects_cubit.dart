import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający listą projektów
class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository projectsRepository;

  late StreamSubscription<List<Project>> projectsSubscription;

  bool _acceptStreamUpdates = true;

  ProjectsCubit({
    required this.projectsRepository,
  }) : super(const ProjectsInitial()) {
    loadProjects();
  }

  @override
  Future<void> close() {
    projectsSubscription.cancel();
    return super.close();
  }

  Future<void> loadProjects() async {
    final response = await projectsRepository.getProjects();
    final cached = response.cached;
    final stream = response.stream;

    if (cached != null) {
      emit(ProjectsRefreshing(cached));
    } else {
      emit(const ProjectsLoading());
    }

    projectsSubscription =
        stream.listen((
          projects,
        ) {
          if (!_acceptStreamUpdates) return;

          emit(ProjectsReady(projects));
        })..onError(
          (error) {
            final currentState = state;
            if (currentState is ProjectsRefreshing) {
              emit(
                ProjectsRefreshFailure(currentState.projects, error.toString()),
              );
            } else {
              emit(ProjectsLoadFailure(error.toString()));
            }
          },
        );
  }

  Future<void> refreshProjects() async {
    final currentState = state;

    if (currentState is ProjectsReady) {
      try {
        emit(ProjectsRefreshing(currentState.projects));
        await Future.delayed(const Duration(milliseconds: 500));
        await projectsRepository.refreshProjects();
      } catch (e) {
        emit(ProjectsRefreshFailure(currentState.projects, e.toString()));
      }
    }
  }

  void pauseUpdates() => _acceptStreamUpdates = false;
  void resumeUpdates() => _acceptStreamUpdates = true;
}
