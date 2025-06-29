import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/song_detail.dart';
import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/repositories/song_repository.dart';
import 'package:bandspace_mobile/song_detail/cubit/song_detail_state.dart';

/// Cubit zarządzający stanem ekranu szczegółów utworu
class SongDetailCubit extends Cubit<SongDetailState> {
  final SongRepository songRepository;
  final int projectId;
  final int songId;

  SongDetailCubit({
    required this.songRepository,
    required this.projectId,
    required this.songId,
  }) : super(const SongDetailState());

  /// Ładuje szczegóły utworu wraz z listą plików
  Future<void> loadSongDetail() async {
    if (state.status == SongDetailStatus.loading) return;

    emit(state.copyWith(
      status: SongDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      // Równoległe ładowanie szczegółów utworu i plików
      final results = await Future.wait([
        songRepository.getSongDetails(projectId: projectId, songId: songId),
        songRepository.getSongFiles(songId),
      ]);

      final songDetail = results[0] as SongDetail;
      final files = results[1] as List<SongFile>;

      emit(state.copyWith(
        status: SongDetailStatus.loaded,
        songDetail: songDetail,
        files: files,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: SongDetailStatus.error,
        errorMessage: 'Błąd podczas ładowania utworu: ${e.message}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SongDetailStatus.error,
        errorMessage: 'Wystąpił nieoczekiwany błąd: $e',
      ));
    }
  }

  /// Odświeża listę plików
  Future<void> refreshFiles() async {
    if (state.fileOperationStatus == FileOperationStatus.loading) return;

    emit(state.copyWith(
      fileOperationStatus: FileOperationStatus.loading,
      fileOperationError: null,
    ));

    try {
      final files = await songRepository.getSongFiles(songId);
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.success,
        files: files,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.error,
        fileOperationError: 'Błąd podczas odświeżania plików: ${e.message}',
      ));
    } catch (e) {
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.error,
        fileOperationError: 'Wystąpił nieoczekiwany błąd: $e',
      ));
    }
  }

  /// Usuwa plik z utworu
  Future<void> deleteFile(int fileId) async {
    if (state.fileOperationStatus == FileOperationStatus.loading) return;

    emit(state.copyWith(
      fileOperationStatus: FileOperationStatus.loading,
      fileOperationError: null,
    ));

    try {
      await songRepository.deleteSongFile(songId: songId, fileId: fileId);
      
      // Usuń plik z lokalnej listy
      final updatedFiles = state.files.where((file) => file.fileId != fileId).toList();
      
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.success,
        files: updatedFiles,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.error,
        fileOperationError: 'Błąd podczas usuwania pliku: ${e.message}',
      ));
    } catch (e) {
      emit(state.copyWith(
        fileOperationStatus: FileOperationStatus.error,
        fileOperationError: 'Wystąpił nieoczekiwany błąd: $e',
      ));
    }
  }

  /// Aktualizuje metadane utworu
  Future<void> updateSong({
    String? title,
    String? notes,
    int? bpm,
    String? key,
    String? lyrics,
  }) async {
    if (state.isUpdatingSong) return;

    emit(state.copyWith(
      isUpdatingSong: true,
      errorMessage: null,
    ));

    try {
      final updatedSong = await songRepository.updateSong(
        projectId: projectId,
        songId: songId,
        title: title,
        notes: notes,
        bpm: bpm,
        key: key,
        lyrics: lyrics,
      );

      emit(state.copyWith(
        isUpdatingSong: false,
        songDetail: updatedSong,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        isUpdatingSong: false,
        errorMessage: 'Błąd podczas aktualizacji utworu: ${e.message}',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdatingSong: false,
        errorMessage: 'Wystąpił nieoczekiwany błąd: $e',
      ));
    }
  }

  /// Pobiera URL do streamowania pliku
  Future<String?> getFileStreamUrl(int fileId) async {
    try {
      return await songRepository.getFileDownloadUrl(
        songId: songId,
        fileId: fileId,
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        fileOperationError: 'Błąd podczas pobierania URL pliku: ${e.message}',
      ));
      return null;
    } catch (e) {
      emit(state.copyWith(
        fileOperationError: 'Wystąpił nieoczekiwany błąd: $e',
      ));
      return null;
    }
  }

  /// Czyści komunikat błędu
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  /// Czyści komunikat błędu operacji na plikach
  void clearFileOperationError() {
    if (state.fileOperationError != null) {
      emit(state.copyWith(fileOperationError: null));
    }
  }

}