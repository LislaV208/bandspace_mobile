import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/project/cubit/project_songs_state.dart';

/// Cubit zarządzający stanem utworów projektu
class ProjectSongsCubit extends Cubit<ProjectSongsState> {
  final ProjectRepository projectRepository;
  final int projectId;

  ProjectSongsCubit({
    required this.projectRepository,
    required this.projectId,
  }) : super(const ProjectSongsState());

  /// Pobiera listę utworów dla projektu
  Future<void> loadSongs() async {
    if (state.status == ProjectSongsStatus.loading) return;

    emit(state.copyWith(status: ProjectSongsStatus.loading, errorMessage: null));

    try {
      final songs = await projectRepository.getProjectSongs(projectId);
      emit(state.copyWith(status: ProjectSongsStatus.loaded, songs: songs));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: ProjectSongsStatus.error,
          errorMessage: 'Błąd podczas pobierania utworów: ${e.message}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProjectSongsStatus.error,
          errorMessage: 'Wystąpił nieoczekiwany błąd: $e',
        ),
      );
    }
  }

  /// Tworzy nowy utwór
  Future<void> createSong(String title) async {
    if (title.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Tytuł utworu nie może być pusty'));
      return;
    }

    emit(state.copyWith(isCreatingSong: true, errorMessage: null));

    try {
      final newSong = await projectRepository.createSong(
        projectId: projectId,
        title: title.trim(),
      );

      final updatedSongs = [newSong, ...state.songs];
      emit(
        state.copyWith(
          isCreatingSong: false,
          songs: updatedSongs,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isCreatingSong: false,
          errorMessage: 'Błąd podczas tworzenia utworu: ${e.message}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCreatingSong: false,
          errorMessage: 'Wystąpił nieoczekiwany błąd: $e',
        ),
      );
    }
  }

  /// Usuwa utwór
  Future<void> deleteSong(Song song) async {
    emit(state.copyWith(isDeletingSong: true, errorMessage: null));

    try {
      await projectRepository.deleteSong(
        projectId: projectId,
        songId: song.id,
      );

      final updatedSongs = state.songs.where((s) => s.id != song.id).toList();
      emit(
        state.copyWith(
          isDeletingSong: false,
          songs: updatedSongs,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          isDeletingSong: false,
          errorMessage: 'Błąd podczas usuwania utworu: ${e.message}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDeletingSong: false,
          errorMessage: 'Wystąpił nieoczekiwany błąd: $e',
        ),
      );
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  /// Filtruje utwory na podstawie zapytania
  List<Song> getFilteredSongs(String query) {
    if (query.trim().isEmpty) {
      return state.songs;
    }
    
    final lowerQuery = query.toLowerCase();
    return state.songs
        .where((song) => song.title.toLowerCase().contains(lowerQuery))
        .toList();
  }
}