import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający listą projektów na ekranie dashboardu
class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsRepository projectsRepository;

  late StreamSubscription<List<Project>> projectsSubscription;

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
    emit(const ProjectsLoading());

    projectsSubscription =
        projectsRepository.getProjects().listen((
          projects,
        ) {
          emit(ProjectsLoadSuccess(projects));
        })..onError(
          (error) {
            emit(ProjectsLoadFailure(error.toString()));
          },
        );
  }

  Future<void> refreshProjects() async {
    await projectsRepository.refreshProjects();
  }
}
