import 'dart:developer';
import 'dart:io';
import 'package:bandspace_mobile/core/utils/error_logger.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_state.dart';
import 'package:bandspace_mobile/features/track_versions/models/add_version_data.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class AddTrackVersionCubit extends Cubit<AddTrackVersionState> {
  final ProjectsRepository _repository;
  final int projectId;
  final int trackId;
  final Track track;

  AddTrackVersionCubit({
    required ProjectsRepository repository,
    required this.projectId,
    required this.trackId,
    required this.track,
  }) : _repository = repository,
       super(const AddTrackVersionInitial());

  /// Krok 1: Wybór pliku audio
  Future<void> selectFile() async {
    emit(const AddTrackVersionSelecting());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = file.path.split('/').last;

        // Inicjalizuj metadata z BPM z głównej wersji jeśli dostępne
        final initialMetadata = AddVersionData(bpm: track.mainVersion?.bpm);

        emit(
          AddTrackVersionFileSelected(
            file: file,
            fileName: fileName,
            metadata: initialMetadata,
          ),
        );
      } else {
        // Użytkownik anulował wybór pliku
        emit(const AddTrackVersionInitial());
      }
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to select audio file for track version',
      );
      emit(
        AddTrackVersionFailure(
          'Błąd podczas wybierania pliku: ${e.toString()}',
        ),
      );
    }
  }

  /// Krok 2: Aktualizacja metadanych (BPM)
  void updateMetadata(AddVersionData newMetadata) {
    final currentState = state;
    if (currentState is AddTrackVersionFileSelected) {
      emit(
        AddTrackVersionFileSelected(
          file: currentState.file,
          fileName: currentState.fileName,
          metadata: newMetadata,
        ),
      );
    } else if (currentState is AddTrackVersionReadyToUpload) {
      emit(
        AddTrackVersionReadyToUpload(
          file: currentState.file,
          fileName: currentState.fileName,
          metadata: newMetadata,
        ),
      );
    }
  }

  /// Przejście do gotowości uploadu (po uzupełnieniu metadanych)
  void proceedToUpload() {
    final currentState = state;
    if (currentState is AddTrackVersionFileSelected) {
      if (currentState.metadata.isValid) {
        emit(
          AddTrackVersionReadyToUpload(
            file: currentState.file,
            fileName: currentState.fileName,
            metadata: currentState.metadata,
          ),
        );
      } else {
        emit(const AddTrackVersionFailure('Metadane są nieprawidłowe'));
      }
    }
  }

  /// Krok 3: Upload pliku
  Future<void> uploadVersion() async {
    final currentState = state;
    if (currentState is! AddTrackVersionReadyToUpload) {
      emit(const AddTrackVersionFailure('Nieprawidłowy stan do uploadu'));
      return;
    }

    emit(
      AddTrackVersionUploading(
        progress: 0.0,
        file: currentState.file,
        fileName: currentState.fileName,
        metadata: currentState.metadata,
      ),
    );

    try {
      // Włącz Wake Lock aby zapobiec uśpieniu urządzenia podczas uploadu
      await WakelockPlus.enable();
      log(
        'Wake Lock enabled for version upload: ${currentState.fileName}',
        name: 'AddTrackVersionCubit',
      );

      final newVersion = await _repository.addTrackVersion(
        projectId,
        trackId,
        currentState.file,
        bpm: currentState.metadata.bpm,
        onProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            emit(
              AddTrackVersionUploading(
                progress: progress,
                file: currentState.file,
                fileName: currentState.fileName,
                metadata: currentState.metadata,
              ),
            );
          }
        },
      );

      emit(AddTrackVersionSuccess(newVersion));
      log(
        'Version upload completed successfully: ${currentState.fileName}',
        name: 'AddTrackVersionCubit',
      );
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to upload track version: ${currentState.fileName}',
      );
      log('AddTrackVersion error: $e', name: 'AddTrackVersionCubit');
      log('Stack trace: $stackTrace', name: 'AddTrackVersionCubit');
      emit(
        AddTrackVersionFailure(
          'Błąd podczas uploadu: ${e.toString()}',
          file: currentState.file,
          fileName: currentState.fileName,
          metadata: currentState.metadata,
        ),
      );
    } finally {
      // Zawsze wyłącz Wake Lock po zakończeniu uploadu (sukces lub błąd)
      await WakelockPlus.disable();
      log(
        'Wake Lock disabled after version upload',
        name: 'AddTrackVersionCubit',
      );
    }
  }

  /// Reset do stanu początkowego
  void reset() {
    emit(const AddTrackVersionInitial());
  }

  /// Powrót do poprzedniego kroku
  void goBack() {
    final currentState = state;
    switch (currentState) {
      case AddTrackVersionFileSelected():
        emit(const AddTrackVersionInitial());
        break;
      case AddTrackVersionReadyToUpload():
        emit(
          AddTrackVersionFileSelected(
            file: currentState.file,
            fileName: currentState.fileName,
            metadata: currentState.metadata,
          ),
        );
        break;
      case AddTrackVersionFailure():
        // Powrót do kroku metadanych jeśli są dostępne dane
        if (currentState.file != null &&
            currentState.fileName != null &&
            currentState.metadata != null) {
          emit(
            AddTrackVersionFileSelected(
              file: currentState.file!,
              fileName: currentState.fileName!,
              metadata: currentState.metadata!,
            ),
          );
        } else {
          emit(const AddTrackVersionInitial());
        }
        break;
      default:
        // Inne stany nie obsługują powrotu
        break;
    }
  }

  /// Ponów próbę uploadu po błędzie
  void retryUpload() {
    final currentState = state;
    if (currentState is AddTrackVersionFailure &&
        currentState.file != null &&
        currentState.fileName != null &&
        currentState.metadata != null) {
      emit(
        AddTrackVersionReadyToUpload(
          file: currentState.file!,
          fileName: currentState.fileName!,
          metadata: currentState.metadata!,
        ),
      );
      uploadVersion();
    }
  }
}
