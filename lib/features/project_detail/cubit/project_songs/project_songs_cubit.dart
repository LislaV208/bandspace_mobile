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
    final response = await projectsRepository.getSongs(projectId);
    final cached = response.cached;
    final stream = response.stream;

    if (cached != null) {
      emit(ProjectSongsRefreshing(cached));
    } else {
      emit(const ProjectSongsLoading());
    }

    _songsSubscription =
        stream.listen((songs) async {
          await Future.delayed(const Duration(milliseconds: 500));

          emit(ProjectSongsReady(songs));
        })..onError((error) {
          final currentState = state;
          if (currentState is ProjectSongsReady) {
            emit(
              ProjectSongsRefreshFailure(currentState.songs, error.toString()),
            );
          } else {
            emit(ProjectSongsLoadFailure(error.toString()));
          }
        });
  }

  Future<void> refreshSongs() async {
    final currentState = state;

    if (currentState is ProjectSongsRefreshing) return;

    if (currentState is ProjectSongsReady) {
      try {
        emit(ProjectSongsRefreshing(currentState.songs));
        await Future.delayed(const Duration(milliseconds: 500));
        await projectsRepository.refreshSongs(projectId);
      } catch (e) {
        emit(ProjectSongsRefreshFailure(currentState.songs, e.toString()));
      }
    } else if (currentState is ProjectSongsLoadFailure) {
      try {
        emit(const ProjectSongsLoading());
        await projectsRepository.refreshSongs(projectId);
      } catch (e) {
        emit(ProjectSongsLoadFailure(e.toString()));
      }
    }
  }

  Future<void> filterSongs(String query) async {
    if (state is ProjectSongsReady) {
      final currentState = state as ProjectSongsReady;
      final filteredSongs = currentState.songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(ProjectSongsFiltered(currentState.songs, filteredSongs));
    }
  }
}
