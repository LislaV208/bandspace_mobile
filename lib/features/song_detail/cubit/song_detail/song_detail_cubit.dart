import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bandspace_mobile/core/utils/error_logger.dart';

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

    log(
      'Songs in SongDetailCubit: ${state.songs.map((s) => '${s.id}:${s.title}').toList()}',
    );
    _downloadUrls();
  }

  void selectSong(Song song) {
    // Przeładuj URL-e tylko jeśli jeszcze ich nie mamy
    if (state is! SongDetailLoadUrlsSuccess) {
      // Emit SongDetailReady przed ładowaniem URL-ów
      emit(
        SongDetailReady(
          state.songs,
          song,
        ),
      );
      _downloadUrls();
    } else {
      // Jeśli już mamy URL-e, przejdź bezpośrednio do SongDetailLoadUrlsSuccess
      // bez przechodzenia przez SongDetailReady
      final urlsState = state as SongDetailLoadUrlsSuccess;
      emit(
        SongDetailLoadUrlsSuccess(
          state.songs,
          song, // zaktualizowany currentSong
          urlsState.downloadUrls,
        ),
      );
    }
  }

  void setReady() {
    // Nie przechodź do SongDetailReady jeśli już mamy informacje o URL-ach
    if (state is SongDetailLoadUrlsSuccess) {
      return; // Zostań w SongDetailLoadUrlsSuccess
    }
    emit(SongDetailReady(state.songs, state.currentSong));
  }

  // === METODY NAWIGACYJNE ===

  /// Przechodzi do następnego utworu w liście (niezależnie od pliku audio)
  void goToNextSong() {
    final currentIndex = state.currentSongIndex;
    if (currentIndex < state.songs.length - 1) {
      final nextSong = state.songs[currentIndex + 1];
      selectSong(nextSong);
    }
  }

  /// Przechodzi do poprzedniego utworu w liście (niezależnie od pliku audio)
  void goToPreviousSong() {
    final currentIndex = state.currentSongIndex;
    if (currentIndex > 0) {
      final previousSong = state.songs[currentIndex - 1];
      selectSong(previousSong);
    }
  }

  /// Sprawdza czy można przejść do następnego utworu
  bool get canGoNext => state.canGoNext;

  /// Sprawdza czy można przejść do poprzedniego utworu
  bool get canGoPrevious => state.canGoPrevious;

  /// Zwraca aktualny indeks utworu w liście wszystkich utworów
  int get currentSongIndex => state.currentSongIndex;

  void updateSong(Song song) {
    final songs = [...state.songs];
    final index = songs.indexWhere((s) => s.id == song.id);

    if (index != -1) {
      songs[index] = song;
      emit(SongDetailReady(songs, song));
      // Pobierz nowe URL-e po aktualizacji utworu
      _downloadUrls();
    }
  }

  Future<void> refreshSong() async {
    try {
      // Odśwież szczegóły utworu
      await projectsRepository.refreshSong(projectId, songId);

      // Odśwież listę utworów
      await projectsRepository.refreshSongs(projectId);

      // Odśwież URL-e
      await _downloadUrls();
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to refresh song details',
      );
      log('Error refreshing song: $e');
    }
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
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to download song playlist URLs',
      );
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

    final songs = [...state.songs];

    final songsDifference = songs
      ..removeWhere(
        (song) => urls.songUrls.any((su) => song.id == su.songId),
      );

    if (songsDifference.isNotEmpty) return false;

    return true;
  }
}
