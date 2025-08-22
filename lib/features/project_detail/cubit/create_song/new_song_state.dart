import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class NewSongState extends Equatable {
  const NewSongState();

  @override
  List<Object?> get props => [];
}

class NewSongInitial extends NewSongState {
  const NewSongInitial();
}

class NewSongSelectingFile extends NewSongState {
  const NewSongSelectingFile();
}

class NewSongSelectFileFailure extends NewSongState {
  final String message;

  const NewSongSelectFileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class NewSongFileSelected extends NewSongState {
  final File? file;
  final String songInitialName;

  const NewSongFileSelected({this.file, this.songInitialName = 'Nowy utwór'});

  @override
  List<Object?> get props => [file, songInitialName];
}

class NewSongUploading extends NewSongState {
  final double uploadProgress;
  final String songName;

  const NewSongUploading(this.uploadProgress, this.songName);

  @override
  List<Object?> get props => [uploadProgress, songName];
}

class NewSongUploadFailure extends NewSongUploading {
  final String message;

  const NewSongUploadFailure(
    super.uploadProgress,
    super.songName,
    this.message,
  );

  @override
  List<Object?> get props => [uploadProgress, songName, message];
}

class NewSongUploadSuccess extends NewSongUploading {
  const NewSongUploadSuccess(super.uploadProgress, super.songName);
}
