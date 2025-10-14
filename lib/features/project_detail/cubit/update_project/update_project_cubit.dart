import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/update_project/update_project_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class UpdateProjectCubit extends Cubit<UpdateProjectState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  UpdateProjectCubit({
    required this.projectsRepository,
    required this.projectId,
  }) : super(const UpdateProjectInitial());

  Future<void> updateProject(String name) async {
    emit(const UpdateProjectLoading());

    try {
      await projectsRepository.updateProject(
        projectId: projectId,
        name: name,
      );

      await projectsRepository.refreshProjects();

      emit(const UpdateProjectSuccess());
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to update project',
        extras: {'projectId': projectId, 'newName': name},
      );
      emit(UpdateProjectFailure(e.toString()));
    }
  }
}
