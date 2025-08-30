import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CreateTrackState extends Equatable {
  const CreateTrackState();

  @override
  List<Object?> get props => [];
}

class CreateTrackInitial extends CreateTrackState {
  const CreateTrackInitial();
}

class CreateTrackSelectingFile extends CreateTrackState {
  const CreateTrackSelectingFile();
}

class CreateTrackSelectFileFailure extends CreateTrackState {
  final String message;

  const CreateTrackSelectFileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateTrackFileSelected extends CreateTrackState {
  final File? file;
  final String trackInitialName;

  const CreateTrackFileSelected({this.file, this.trackInitialName = 'Nowy utwór'});

  @override
  List<Object?> get props => [file, trackInitialName];
}

class CreateTrackUploading extends CreateTrackState {
  final double uploadProgress;
  final String trackName;
  final bool hasFile;

  const CreateTrackUploading(this.uploadProgress, this.trackName, {this.hasFile = true});

  @override
  List<Object?> get props => [uploadProgress, trackName, hasFile];
}

class CreateTrackUploadFailure extends CreateTrackUploading {
  final String message;

  const CreateTrackUploadFailure(
    super.uploadProgress,
    super.trackName,
    this.message,
  );

  @override
  List<Object?> get props => [uploadProgress, trackName, message];
}

class CreateTrackUploadSuccess extends CreateTrackUploading {
  const CreateTrackUploadSuccess(super.uploadProgress, super.trackName);
}