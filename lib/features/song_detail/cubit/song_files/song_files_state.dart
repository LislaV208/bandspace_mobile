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
  final SongFile? selectedFile;

  const SongFilesLoadSuccess(this.files, {this.selectedFile});

  @override
  List<Object?> get props => [files, selectedFile];
}

class SongFilesLoadFailure extends SongFilesState {
  final String message;

  const SongFilesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
