import 'dart:async';

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
  }) : super(SongDetailInitial(initialSong)) {
    loadSongDetail();
  }

  late StreamSubscription<Song> _songSubscription;

  @override
  Future<void> close() {
    _songSubscription.cancel();
    return super.close();
  }

  var _acceptStreamUpdates = true;

  Future<void> loadSongDetail() async {
    emit(SongDetailLoading(state.song));

    _songSubscription =
        projectsRepository.getSong(projectId, songId).listen((song) async {
          if (!_acceptStreamUpdates) return;

          emit(SongDetailLoadSuccess(song));

          _loadSongFileUrl(song);
        })..onError((error) {
          emit(SongDetailLoadFailure(state.song, error.toString()));
        });
  }

  Future<void> refreshSongDetail({bool showLoading = false}) async {
    if (showLoading) {
      emit(SongDetailLoading(state.song));
    }

    await projectsRepository.refreshSong(projectId, songId);
  }

  void pauseUpdates() => _acceptStreamUpdates = false;
  void resumeUpdates() => _acceptStreamUpdates = true;

  Future<void> _loadSongFileUrl(Song song) async {
    if (song.downloadUrl != null) {
      emit(SongFileUrlLoadSuccess(song, song.downloadUrl!));
      return;
    }

    emit(SongFileUrlLoading(song));

    try {
      final url = await projectsRepository.getSongDownloadUrl(
        projectId,
        songId,
      );

      emit(SongFileUrlLoadSuccess(song, url));
    } catch (e) {
      emit(SongFileUrlLoadFailure(song, e.toString()));
    }
  }
}
