import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';

abstract class AddSongFileState extends Equatable {
  const AddSongFileState();

  @override
  List<Object?> get props => [];
}

class AddSongFileInitial extends AddSongFileState {
  const AddSongFileInitial();
}

class AddSongFileSelecting extends AddSongFileState {
  const AddSongFileSelecting();
}

class AddSongFileSelected extends AddSongFileState {
  final File file;
  final String fileName;

  const AddSongFileSelected(this.file, this.fileName);

  @override
  List<Object?> get props => [file, fileName];
}

class AddSongFileUploading extends AddSongFileState {
  final double uploadProgress;

  const AddSongFileUploading(this.uploadProgress);

  @override
  List<Object?> get props => [uploadProgress];
}

class AddSongFileSuccess extends AddSongFileState {
  final Song updatedSong;

  const AddSongFileSuccess(this.updatedSong);

  @override
  List<Object?> get props => [updatedSong];
}

class AddSongFileFailure extends AddSongFileState {
  final String message;

  const AddSongFileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
