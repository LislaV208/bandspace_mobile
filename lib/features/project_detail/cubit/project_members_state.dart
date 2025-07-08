import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/models/project_member.dart';

enum ProjectMembersStatus {
  initial,
  loading,
  success,
  error,
}

class ProjectMembersState extends Equatable {
  final ProjectMembersStatus status;
  final List<ProjectMember> members;
  final String? errorMessage;

  const ProjectMembersState({
    this.status = ProjectMembersStatus.initial,
    this.members = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    members,
    errorMessage,
  ];

  ProjectMembersState copyWith({
    ProjectMembersStatus? status,
    List<ProjectMember>? members,
    Value<String?>? errorMessage,
  }) {
    return ProjectMembersState(
      status: status ?? this.status,
      members: members ?? this.members,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
    );
  }
}
