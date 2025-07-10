import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongDetailCubit extends Cubit<SongDetailState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  SongDetailCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
    required Song initialSong,
  }) : super(SongDetailState(initialSong)) {
    loadSongDetail();
  }

  var _acceptStreamUpdates = true;

  Future<void> loadSongDetail() async {
    projectsRepository
        .getSong(projectId, songId)
        .listen((song) {
          if (!_acceptStreamUpdates) return;

          emit(SongDetailState(song));
        })
        .onError((error) {
          emit(SongDetailLoadFailure(state.song, error.toString()));
        });
  }

  Future<void> refreshSongDetail() async {
    await projectsRepository.refreshSong(projectId, songId);
  }

  void pauseUpdates() => _acceptStreamUpdates = false;
  void resumeUpdates() => _acceptStreamUpdates = true;
}
