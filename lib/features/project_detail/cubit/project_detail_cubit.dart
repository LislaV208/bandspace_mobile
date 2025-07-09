import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_state.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_detail_repository.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectDetailRepository projectRepository;
  final int projectId;

  ProjectDetailCubit({
    required this.projectRepository,
    required this.projectId,
    Project? initialProject,
  }) : super(ProjectDetailState(project: initialProject)) {
    loadProjectDetail();
  }

  late StreamSubscription<Project> _projectSubscription;

  @override
  Future<void> close() {
    _projectSubscription.cancel();

    return super.close();
  }

  Future<void> loadProjectDetail() async {
    emit(state.copyWith(status: ProjectDetailStatus.loading));

    _projectSubscription =
        projectRepository.getProject(projectId).listen((project) {
          if (state.status == ProjectDetailStatus.deleting) return;

          emit(
            state.copyWith(
              status: ProjectDetailStatus.success,
              project: Value(project),
            ),
          );
        })..onError((error) {
          emit(
            state.copyWith(
              status: ProjectDetailStatus.error,
              errorMessage: Value(error.toString()),
            ),
          );
        });
  }

  Future<bool> deleteProject() async {
    try {
      emit(state.copyWith(status: ProjectDetailStatus.deleting));

      await projectRepository.deleteProject(projectId);

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectDetailStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
      return false;
    }
  }

  Future<bool> updateProject({
    required String name,
  }) async {
    try {
      emit(state.copyWith(status: ProjectDetailStatus.updating));

      final updatedProject = await projectRepository.updateProject(
        projectId: projectId,
        name: name,
      );

      emit(
        state.copyWith(
          status: ProjectDetailStatus.success,
          project: Value(updatedProject),
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectDetailStatus.error,
          errorMessage: Value(e.toString()),
        ),
      );
      return false;
    }
  }
}
