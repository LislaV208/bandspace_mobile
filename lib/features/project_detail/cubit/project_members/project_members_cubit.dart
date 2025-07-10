import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_members/project_members_state.dart';
import 'package:bandspace_mobile/shared/models/project_member.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ProjectMembersCubit extends Cubit<ProjectMembersState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  late StreamSubscription<List<ProjectMember>> _membersSubscription;

  ProjectMembersCubit({
    required this.projectsRepository,
    required this.projectId,
  }) : super(const ProjectMembersInitial()) {
    loadProjectMembers();
  }

  @override
  Future<void> close() {
    _membersSubscription.cancel();
    return super.close();
  }

  void loadProjectMembers() {
    emit(const ProjectMembersLoading());

    _membersSubscription =
        projectsRepository.getProjectMembers(projectId).listen(
          (members) {
            emit(ProjectMembersLoadSuccess(members));
          },
        )..onError((error) {
          emit(ProjectMembersLoadFailure(error.toString()));
        });
  }

  void refreshProjectMembers() {
    projectsRepository.refreshProjectMembers(projectId);
  }
}
