import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';

class ProjectDetailState extends Equatable {
  final Project project;

  const ProjectDetailState(this.project);

  @override
  List<Object?> get props => [project];
}

class ProjectDetailLoadFailure extends ProjectDetailState {
  final String message;

  const ProjectDetailLoadFailure(super.project, this.message);

  @override
  List<Object?> get props => [project, message];
}
