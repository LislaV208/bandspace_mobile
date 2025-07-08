import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_members_state.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_members_repository.dart';
import 'package:bandspace_mobile/shared/models/project_member.dart';

class ProjectMembersCubit extends Cubit<ProjectMembersState> {
  final ProjectMembersRepository projectMembersRepository;
  final int projectId;

  late StreamSubscription<List<ProjectMember>> _membersSubscription;

  ProjectMembersCubit({
    required this.projectMembersRepository,
    required this.projectId,
  }) : super(const ProjectMembersState()) {
    loadProjectMembers();
  }

  @override
  Future<void> close() {
    _membersSubscription.cancel();
    return super.close();
  }

  void loadProjectMembers() {
    emit(state.copyWith(status: ProjectMembersStatus.loading));

    _membersSubscription =
        projectMembersRepository.getProjectMembers(projectId).listen(
          (members) {
            emit(
              state.copyWith(
                status: ProjectMembersStatus.success,
                members: members,
              ),
            );
          },
        )..onError((error) {
          emit(
            state.copyWith(
              status: ProjectMembersStatus.error,
              errorMessage: Value(error.toString()),
            ),
          );
        });
  }
}
