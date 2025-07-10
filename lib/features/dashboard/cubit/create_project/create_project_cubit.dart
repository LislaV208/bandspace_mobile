import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/create_project/create_project_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class CreateProjectCubit extends Cubit<CreateProjectState> {
  final ProjectsRepository projectsRepository;

  CreateProjectCubit({
    required this.projectsRepository,
  }) : super(const CreateProjectInitial());

  Future<void> createProject(String name) async {
    emit(const CreateProjectLoading());

    try {
      final project = await projectsRepository.createProject(name: name.trim());
      emit(CreateProjectSuccess(project));
    } catch (e) {
      emit(CreateProjectFailure(e.toString()));
    }
  }
}
