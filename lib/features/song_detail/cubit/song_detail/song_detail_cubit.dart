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
  }) : super(SongDetailState(songs, currentSong));

  void nextSong() {
    final currentIndex = state.songs.indexOf(state.currentSong);
    final nextIndex = (currentIndex + 1) % state.songs.length;
    final nextSong = state.songs[nextIndex];
    emit(SongDetailState(state.songs, nextSong));
  }

  void previousSong() {
    final currentIndex = state.songs.indexOf(state.currentSong);
    final previousIndex = (currentIndex - 1) % state.songs.length;
    final previousSong = state.songs[previousIndex];
    emit(SongDetailState(state.songs, previousSong));
  }
}
