import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/shared/utils/error_logger.dart';
import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/services/wakelock_service.dart';

class AddTrackFileCubit extends Cubit<AddTrackFileState> {
  final ProjectsRepository projectsRepository;
  final WakelockService wakelockService;
  final int projectId;
  final int trackId;

  AddTrackFileCubit({
    required this.projectsRepository,
    required this.wakelockService,
    required this.projectId,
    required this.trackId,
  }) : super(const AddTrackFileInitial());

  Future<void> selectFile() async {
    emit(const AddTrackFileSelecting());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = file.path.split('/').last;
        emit(AddTrackFileSelected(file, fileName));
      } else {
        emit(const AddTrackFileInitial());
      }
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to select audio file for track',
      );
      emit(AddTrackFileFailure(e.toString()));
    }
  }

  Future<void> uploadFile() async {
    final currentState = state;
    if (currentState is AddTrackFileSelected) {
      final file = currentState.file;
      final fileName = currentState.fileName;

      emit(const AddTrackFileUploading(0.0));

      try {
        await wakelockService.runWithWakelock(
          reason: 'track file upload: $fileName',
          operation: () async {
            final updatedTrack = await projectsRepository.addTrackFile(
              projectId,
              trackId,
              file,
              onProgress: (sent, total) {
                emit(AddTrackFileUploading(sent / total));
              },
            );

            emit(AddTrackFileSuccess(updatedTrack));
            log(
              'Track file upload completed successfully: $fileName',
              name: 'AddTrackFileCubit',
            );
            return updatedTrack;
          },
        );
      } catch (e, stackTrace) {
        logError(
          e,
          stackTrace: stackTrace,
          hint: 'Failed to upload track file: $fileName',
        );
        log(
          'Track file upload failed: $fileName. Error: $e',
          name: 'AddTrackFileCubit',
        );
        emit(AddTrackFileFailure(e.toString()));
      }
    }
  }

  void reset() {
    emit(const AddTrackFileInitial());
  }
}
