import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ProjectSongsCubit extends Cubit<ProjectSongsState> {
  final ProjectsRepository projectsRepository;
  final int projectId;

  ProjectSongsCubit({
    required this.projectsRepository,
    required this.projectId,
  }) : super(const ProjectSongsInitial()) {
    loadSongs();
  }

  late StreamSubscription<List<Song>> _songsSubscription;

  @override
  Future<void> close() {
    _songsSubscription.cancel();

    return super.close();
  }

  Future<void> loadSongs() async {
    emit(const ProjectSongsLoading());

    _songsSubscription =
        projectsRepository.getSongs(projectId).listen((songs) {
          emit(ProjectSongsLoadSuccess(songs));
        })..onError((error) {
          emit(ProjectSongsLoadFailure(error.toString()));
        });
  }

  Future<void> refreshSongs() async {
    await projectsRepository.refreshSongs(projectId);
  }

  Future<void> filterSongs(String query) async {
    if (state is ProjectSongsLoadSuccess) {
      final currentState = state as ProjectSongsLoadSuccess;
      final filteredSongs = currentState.songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(ProjectSongsFiltered(currentState.songs, filteredSongs));
    }
  }
}
