import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ProjectSongsCubit extends Cubit<ProjectSongsState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  ProjectSongsCubit({
    required this.projectsRepository,
    required this.projectId,
  }) : super(const ProjectSongsState()) {
    loadSongs();
  }

  late StreamSubscription<List<Song>> _songsSubscription;

  @override
  Future<void> close() {
    _songsSubscription.cancel();

    return super.close();
  }

  Future<void> loadSongs() async {
    emit(state.copyWith(status: ProjectSongsStatus.loading));

    _songsSubscription =
        projectsRepository.getSongs(projectId).listen((songs) {
          emit(
            state.copyWith(
              status: ProjectSongsStatus.success,
              songs: songs,
            ),
          );
        })..onError((error) {
          emit(
            state.copyWith(
              status: ProjectSongsStatus.error,
              errorMessage: Value(error.toString()),
            ),
          );
        });
  }
}
