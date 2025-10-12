import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_track/create_track_state.dart';
import 'package:bandspace_mobile/shared/models/track_create_data.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający stanem tworzenia nowego utworu (Track)
class CreateTrackCubit extends Cubit<CreateTrackState> {
  final int projectId;
  final ProjectsRepository projectsRepository;

  CreateTrackCubit({
    required this.projectId,
    required this.projectsRepository,
  }) : super(const CreateTrackInitial());

  Future<void> selectFile() async {
    emit(const CreateTrackSelectingFile());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final trackInitialName = file.path.split('/').last.split('.').first;
        emit(
          CreateTrackFileSelected(
            file: file,
            trackInitialName: trackInitialName,
          ),
        );
      } else {
        emit(const CreateTrackInitial());
      }
    } catch (e) {
      emit(CreateTrackSelectFileFailure(e.toString()));
    }
  }

  void skipFileSelection() {
    emit(const CreateTrackFileSelected());
  }

  Future<void> uploadFile(CreateTrackData trackData) async {
    final currentState = state;

    if (currentState is CreateTrackFileSelected) {
      final trackName = trackData.title;
      final hasFile = currentState.file != null;

      emit(CreateTrackUploading(0.0, trackName, hasFile: hasFile));

      try {
        // Włącz Wake Lock aby zapobiec uśpieniu urządzenia podczas uploadu
        await WakelockPlus.enable();
        log(
          'Wake Lock enabled for track upload: $trackName',
          name: 'CreateTrackCubit',
        );

        await projectsRepository.createTrack(
          projectId,
          trackData,
          currentState.file,
          onProgress: (sent, total) {
            emit(
              CreateTrackUploading(sent / total, trackName, hasFile: hasFile),
            );
          },
        );

        emit(CreateTrackUploadSuccess(1.0, trackName));
        log(
          'Track upload completed successfully: $trackName',
          name: 'CreateTrackCubit',
        );
      } catch (e) {
        final progress = state is CreateTrackUploading
            ? (state as CreateTrackUploading).uploadProgress
            : 0.0;
        log(
          'Track upload failed: $trackName at ${(progress * 100).toStringAsFixed(1)}% progress. Error: $e',
          name: 'CreateTrackCubit',
        );
        emit(CreateTrackUploadFailure(progress, trackName, e.toString()));
      } finally {
        // Zawsze wyłącz Wake Lock po zakończeniu uploadu (sukces lub błąd)
        await WakelockPlus.disable();
        log('Wake Lock disabled after track upload', name: 'CreateTrackCubit');
      }
    }
  }

  void goToInitialStep() {
    emit(const CreateTrackInitial());
  }
}
