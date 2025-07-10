import 'package:equatable/equatable.dart';

abstract class DeleteProjectState extends Equatable {
  const DeleteProjectState();

  @override
  List<Object?> get props => [];
}

class DeleteProjectInitial extends DeleteProjectState {
  const DeleteProjectInitial();
}

class DeleteProjectLoading extends DeleteProjectState {
  const DeleteProjectLoading();
}

class DeleteProjectSuccess extends DeleteProjectState {
  const DeleteProjectSuccess();
}

class DeleteProjectFailure extends DeleteProjectState {
  final String message;

  const DeleteProjectFailure(this.message);

  @override
  List<Object?> get props => [message];
}
