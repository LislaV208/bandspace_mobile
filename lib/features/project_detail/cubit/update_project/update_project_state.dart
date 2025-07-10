import 'package:equatable/equatable.dart';

abstract class UpdateProjectState extends Equatable {
  const UpdateProjectState();

  @override
  List<Object?> get props => [];
}

class UpdateProjectInitial extends UpdateProjectState {
  const UpdateProjectInitial();
}

class UpdateProjectLoading extends UpdateProjectState {
  const UpdateProjectLoading();
}

class UpdateProjectSuccess extends UpdateProjectState {
  const UpdateProjectSuccess();
}

class UpdateProjectFailure extends UpdateProjectState {
  final String message;

  const UpdateProjectFailure(this.message);

  @override
  List<Object?> get props => [message];
}
