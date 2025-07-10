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

  Future<void> loadSongDetail() async {
    projectsRepository
        .getSong(projectId, songId)
        .listen((song) {
          emit(SongDetailState(song));
        })
        .onError((error) {
          emit(SongDetailLoadFailure(state.song, error.toString()));
        });
  }
}
