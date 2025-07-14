import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/storage/shared_preferences_storage.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/song_download_url.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongDetailCubit extends Cubit<SongDetailState> {
  final SharedPreferencesStorage sharedPreferencesStorage;
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  SongDetailCubit({
    required this.sharedPreferencesStorage,
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
      final key = '${projectId}_urls';
      final data = await sharedPreferencesStorage.getString(key);

      var refreshUrls = true;

      log('Data: $data');

      if (data != null) {
        final downloadUrls = SongListDownloadUrls.fromJson(jsonDecode(data));
        log('Expires at: ${downloadUrls.expiresAt}');
        final areExpired = downloadUrls.expiresAt.isBefore(DateTime.now());
        log('Are expired: $areExpired');
        final isLengthValid =
            downloadUrls.songUrls.length == state.songs.length;
        log('Is length valid: $isLengthValid');

        if (!areExpired && isLengthValid) {
          refreshUrls = false;
          log('Urls are still valid');
          emit(
            SongDetailLoadUrlsSuccess(
              state.songs,
              state.currentSong,
              downloadUrls,
            ),
          );
        }
      }

      log('Refresh urls: $refreshUrls');

      if (refreshUrls) {
        await sharedPreferencesStorage.remove(key);

        emit(SongDetailLoadUrls(state.songs, state.currentSong));
        final downloadUrls = await projectsRepository.getPlaylistDownloadUrls(
          projectId,
        );

        log('Downloaded urls: ${downloadUrls.songUrls}');

        emit(
          SongDetailLoadUrlsSuccess(
            state.songs,
            state.currentSong,
            downloadUrls,
          ),
        );

        await sharedPreferencesStorage.setString(
          key,
          jsonEncode(downloadUrls.toJson()),
        );
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
}
