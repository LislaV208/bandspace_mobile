import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

enum ProjectDetailStatus {
  initial,
  loading,
  success,
  creating,
  deleting,
  error,
}

class ProjectDetailState extends Equatable {
  final ProjectDetailStatus status;

  final Project? project;
  final String? errorMessage;

  const ProjectDetailState({
    this.status = ProjectDetailStatus.loading,
    this.project,
    this.errorMessage,
  });

  ProjectDetailState copyWith({
    ProjectDetailStatus? status,
    Value<Project?>? project,
    Value<String?>? errorMessage,
  }) {
    return ProjectDetailState(
      status: status ?? this.status,
      project: project != null ? project.value : this.project,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    project,
    errorMessage,
  ];
}
