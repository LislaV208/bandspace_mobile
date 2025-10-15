import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/track.dart';

abstract class AddTrackFileState extends Equatable {
  const AddTrackFileState();

  @override
  List<Object?> get props => [];
}

class AddTrackFileInitial extends AddTrackFileState {
  const AddTrackFileInitial();
}

class AddTrackFileSelecting extends AddTrackFileState {
  const AddTrackFileSelecting();
}

class AddTrackFileSelected extends AddTrackFileState {
  final File file;
  final String fileName;

  const AddTrackFileSelected(this.file, this.fileName);

  @override
  List<Object?> get props => [file, fileName];
}

class AddTrackFileUploading extends AddTrackFileState {
  final double uploadProgress;

  const AddTrackFileUploading(this.uploadProgress);

  @override
  List<Object?> get props => [uploadProgress];
}

class AddTrackFileSuccess extends AddTrackFileState {
  final Track updatedTrack;

  const AddTrackFileSuccess(this.updatedTrack);

  @override
  List<Object?> get props => [updatedTrack];
}

class AddTrackFileFailure extends AddTrackFileState {
  final String message;

  const AddTrackFileFailure(this.message);

  @override
  List<Object?> get props => [message];
}