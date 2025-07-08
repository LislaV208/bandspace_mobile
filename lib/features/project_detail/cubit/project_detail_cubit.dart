import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail_state.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_repository.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  final ProjectRepository projectRepository;
  final int projectId;

  ProjectDetailCubit({
    required this.projectRepository,
    required this.projectId,
    Project? initialProject,
  }) : super(ProjectDetailState(project: initialProject)) {
    loadProjectDetail();
  }

  Future<void> loadProjectDetail() async {
    emit(state.copyWith(status: ProjectDetailStatus.loading));

    try {
      final project = await projectRepository.getProject(projectId);

      emit(
        state.copyWith(
          project: Value(project),
          status: ProjectDetailStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: Value(e.toString()),
          status: ProjectDetailStatus.error,
        ),
      );
    }
  }
}
