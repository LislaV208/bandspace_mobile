import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/Delete_project/Delete_project_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class DeleteProjectCubit extends Cubit<DeleteProjectState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  DeleteProjectCubit({
    required this.projectsRepository,
    required this.projectId,
  }) : super(const DeleteProjectInitial());

  Future<void> deleteProject() async {
    emit(const DeleteProjectLoading());

    try {
      await projectsRepository.deleteProject(projectId);

      emit(const DeleteProjectSuccess());
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to delete project',
        extras: {'projectId': projectId},
      );
      emit(DeleteProjectFailure(e.toString()));
    }
  }
}
