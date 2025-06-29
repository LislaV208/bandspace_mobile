import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

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

  /// Wybiera i przesyła plik do utworu
  Future<void> pickAndUploadFile({
    String? description,
    int? duration,
  }) async {
    if (state.isUploading || state.isPicking) return;

    emit(state.copyWith(
      uploadStatus: FileUploadStatus.picking,
      uploadError: null,
    ));

    try {
      // Wybieranie pliku
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // Użytkownik anulował wybieranie pliku
        emit(state.copyWith(uploadStatus: FileUploadStatus.idle));
        return;
      }

      final file = File(result.files.first.path!);
      await uploadFile(
        file: file,
        description: description,
        duration: duration,
      );
    } catch (e) {
      emit(state.copyWith(
        uploadStatus: FileUploadStatus.error,
        uploadError: 'Błąd podczas wybierania pliku: $e',
      ));
    }
  }

  /// Przesyła wybrany plik do utworu
  Future<void> uploadFile({
    required File file,
    String? description,
    int? duration,
  }) async {
    if (state.isUploading) return;

    emit(state.copyWith(
      uploadStatus: FileUploadStatus.uploading,
      uploadProgress: 0.0,
      uploadError: null,
    ));

    try {
      final uploadedFile = await songRepository.uploadFile(
        songId: songId,
        file: file,
        description: description,
        duration: duration,
        onProgress: (progress) {
          emit(state.copyWith(uploadProgress: progress));
        },
      );

      // Dodaj nowy plik do listy
      final updatedFiles = [uploadedFile, ...state.files];

      emit(state.copyWith(
        uploadStatus: FileUploadStatus.success,
        files: updatedFiles,
        uploadProgress: 1.0,
      ));

      // Zresetuj status po chwili
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) {
          emit(state.copyWith(
            uploadStatus: FileUploadStatus.idle,
            uploadProgress: 0.0,
          ));
        }
      });
    } on ApiException catch (e) {
      emit(state.copyWith(
        uploadStatus: FileUploadStatus.error,
        uploadError: 'Błąd podczas przesyłania pliku: ${e.message}',
      ));
    } catch (e) {
      emit(state.copyWith(
        uploadStatus: FileUploadStatus.error,
        uploadError: 'Wystąpił nieoczekiwany błąd podczas przesyłania pliku: $e',
      ));
    }
  }

  /// Czyści komunikat błędu operacji na plikach
  void clearFileOperationError() {
    if (state.fileOperationError != null) {
      emit(state.copyWith(fileOperationError: null));
    }
  }

  /// Czyści komunikat błędu uploadu
  void clearUploadError() {
    if (state.uploadError != null) {
      emit(state.copyWith(uploadError: null));
    }
  }

}