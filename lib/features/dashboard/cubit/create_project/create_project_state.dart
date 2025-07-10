import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/project.dart';

abstract class CreateProjectState extends Equatable {
  const CreateProjectState();

  @override
  List<Object?> get props => [];
}

class CreateProjectInitial extends CreateProjectState {
  const CreateProjectInitial();
}

class CreateProjectLoading extends CreateProjectState {
  const CreateProjectLoading();
}

class CreateProjectSuccess extends CreateProjectState {
  final Project project;

  const CreateProjectSuccess(this.project);
}

class CreateProjectFailure extends CreateProjectState {
  final String message;

  const CreateProjectFailure(this.message);
}
