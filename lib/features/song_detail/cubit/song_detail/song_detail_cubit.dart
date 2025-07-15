import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/song_list_urls_cache_storage.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/song_download_url.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongDetailCubit extends Cubit<SongDetailState> {
  final SongListUrlsCacheStorage songListUrlsCacheStorage;
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  SongDetailCubit({
    required this.songListUrlsCacheStorage,
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
    required List<Song> songs,
    required Song currentSong,
  }) : super(SongDetailInitial(songs, currentSong)) {
    log('SongDetailCubit created');
    _downloadUrls();
  }

  void selectSong(Song song) {
    emit(
      SongDetailReady(
        state.songs,
        song,
      ),
    );
  }

  void setReady() {
    emit(SongDetailReady(state.songs, state.currentSong));
  }

  Future<void> _downloadUrls() async {
    try {
      var refreshUrls = true;

      final urls = await songListUrlsCacheStorage.getSongListUrls(projectId);
      final urlsValid = _validateUrls(urls);

      if (urlsValid) {
        refreshUrls = false;
        emit(
          SongDetailLoadUrlsSuccess(
            state.songs,
            state.currentSong,
            urls!,
          ),
        );
      }

      if (refreshUrls) {
        emit(SongDetailLoadUrls(state.songs, state.currentSong));
        final newUrls = await projectsRepository.getPlaylistDownloadUrls(
          projectId,
        );

        emit(
          SongDetailLoadUrlsSuccess(
            state.songs,
            state.currentSong,
            newUrls,
          ),
        );

        songListUrlsCacheStorage.saveSongListUrls(projectId, newUrls);
      }
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

  bool _validateUrls(SongListDownloadUrls? urls) {
    if (urls == null) return false;

    final expired = urls.expiresAt.isBefore(DateTime.now());
    if (expired) return false;

    final songsDifference = state.songs
      ..removeWhere(
        (song) => urls.songUrls.any((su) => song.id == su.songId),
      );

    if (songsDifference.isNotEmpty) return false;

    return true;
  }
}
