import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project_user.dart';

abstract class ProjectMembersState extends Equatable {
  const ProjectMembersState();

  @override
  List<Object?> get props => [];
}

class ProjectMembersInitial extends ProjectMembersState {
  const ProjectMembersInitial();
}

class ProjectMembersLoading extends ProjectMembersState {
  const ProjectMembersLoading();
}

class ProjectMembersLoadSuccess extends ProjectMembersState {
  final List<ProjectMember> members;

  const ProjectMembersLoadSuccess(this.members);

  @override
  List<Object?> get props => [members];
}

class ProjectMembersLoadFailure extends ProjectMembersState {
  final String message;

  const ProjectMembersLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
