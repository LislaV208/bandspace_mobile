import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song_file.dart';

abstract class SongFilesState extends Equatable {
  const SongFilesState();

  @override
  List<Object?> get props => [];
}

class SongFilesInitial extends SongFilesState {
  const SongFilesInitial();
}

class SongFilesLoading extends SongFilesState {
  const SongFilesLoading();
}

class SongFilesLoadSuccess extends SongFilesState {
  final List<SongFile> files;

  const SongFilesLoadSuccess(this.files);

  @override
  List<Object?> get props => [files];
}

class SongFilesLoadFailure extends SongFilesState {
  final String message;

  const SongFilesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SongFilesFileSelected extends SongFilesLoadSuccess {
  final SongFile selectedFile;

  const SongFilesFileSelected(super.files, this.selectedFile);

  @override
  List<Object?> get props => [selectedFile];
}

class SongFilesFileUrlLoaded extends SongFilesFileSelected {
  final String url;

  const SongFilesFileUrlLoaded(super.files, super.selectedFile, this.url);

  @override
  List<Object?> get props => [files, selectedFile, url];
}

class SongFilesFileUrlLoadFailure extends SongFilesFileSelected {
  final String message;

  const SongFilesFileUrlLoadFailure(
    super.files,
    super.selectedFile,
    this.message,
  );

  @override
  List<Object?> get props => [files, selectedFile, message];
}
