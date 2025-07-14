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
    required List<Song> songs,
    required Song currentSong,
  }) : super(SongDetailInitial(songs, currentSong)) {
    _downloadUrls();
  }

  void selectSong(Song song) {
    final currentState = state as SongDetailReady;
    emit(
      SongDetailReady(
        currentState.songs,
        song,
      ),
    );
  }

  void setReady() {
    emit(SongDetailReady(state.songs, state.currentSong));
  }

  Future<void> _downloadUrls() async {
    try {
      emit(SongDetailLoadUrls(state.songs, state.currentSong));
      final downloadUrls = await projectsRepository.getPlaylistDownloadUrls(
        projectId,
      );

      emit(
        SongDetailLoadUrlsSuccess(
          state.songs,
          state.currentSong,
          downloadUrls,
        ),
      );
    } catch (e) {
      emit(
        SongDetailLoadUrlsFailure(
          state.songs,
          state.currentSong,
          e.toString(),
        ),
      );
    }
  }
}
