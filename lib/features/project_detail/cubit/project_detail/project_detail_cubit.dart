import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  ProjectDetailCubit({
    required this.projectsRepository,
    required this.projectId,
    required Project initialProject,
  }) : super(ProjectDetailState(initialProject)) {
    loadProjectData();
  }

  late StreamSubscription<Project> _projectSubscription;

  @override
  Future<void> close() {
    _projectSubscription.cancel();

    return super.close();
  }

  Future<void> loadProjectData() async {
    _projectSubscription =
        projectsRepository.getProject(projectId).listen((project) {
          emit(ProjectDetailState(project));
        })..onError((error) {
          emit(ProjectDetailLoadFailure(state.project, error.toString()));
        });
  }
}
