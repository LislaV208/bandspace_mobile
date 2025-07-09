import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

enum ProjectSongsStatus {
  initial,
  loading,
  success,
  error,
}

class ProjectSongsState extends Equatable {
  final ProjectSongsStatus status;

  final List<Song> songs;
  final String? errorMessage;

  const ProjectSongsState({
    this.status = ProjectSongsStatus.loading,
    this.songs = const [],
    this.errorMessage,
  });

  ProjectSongsState copyWith({
    ProjectSongsStatus? status,
    List<Song>? songs,
    Value<Project?>? project,
    Value<String?>? errorMessage,
  }) {
    return ProjectSongsState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    songs,
    errorMessage,
  ];
}
