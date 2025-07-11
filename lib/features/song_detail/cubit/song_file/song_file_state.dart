import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song_file.dart';

sealed class SongFileState extends Equatable {
  const SongFileState();

  @override
  List<Object?> get props => [];
}

final class SongFileInitial extends SongFileState {
  const SongFileInitial();
}

final class SongFileLoading extends SongFileState {
  const SongFileLoading();
}

final class SongFileLoadSuccess extends SongFileState {
  final SongFile file;

  const SongFileLoadSuccess(this.file);

  @override
  List<Object?> get props => [file];
}

final class SongFileEmpty extends SongFileState {
  const SongFileEmpty();
}

final class SongFileLoadFailure extends SongFileState {
  final String message;

  const SongFileLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class SongFileUrlLoaded extends SongFileLoadSuccess {
  final String url;

  const SongFileUrlLoaded(super.file, this.url);

  @override
  List<Object?> get props => [file, url];
}

final class SongFileUrlLoadFailure extends SongFileLoadSuccess {
  final String message;

  const SongFileUrlLoadFailure(super.file, this.message);

  @override
  List<Object?> get props => [file, message];
}