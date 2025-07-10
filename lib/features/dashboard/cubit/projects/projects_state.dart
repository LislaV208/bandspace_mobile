import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

class ProjectsLoadSuccess extends ProjectsState {
  final List<Project> projects;

  const ProjectsLoadSuccess(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectsLoadFailure extends ProjectsState {
  final String message;

  const ProjectsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProjectsCreatingProjectState extends ProjectsLoadSuccess {
  const ProjectsCreatingProjectState(super.projects);
}

class ProjectsCreatingProjectLoading extends ProjectsCreatingProjectState {
  const ProjectsCreatingProjectLoading(super.projects);
}

class ProjectsCreatingProjectSuccess extends ProjectsCreatingProjectState {
  const ProjectsCreatingProjectSuccess(super.projects);
}

class ProjectsCreatingProjectFailure extends ProjectsCreatingProjectState {
  final String message;

  const ProjectsCreatingProjectFailure(super.projects, this.message);
}
