import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/add_track_file/add_track_file_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class AddTrackFileCubit extends Cubit<AddTrackFileState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int trackId;

  AddTrackFileCubit({
    required this.projectsRepository,
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
    } catch (e) {
      emit(AddTrackFileFailure(e.toString()));
    }
  }

  Future<void> uploadFile() async {
    final currentState = state;
    if (currentState is AddTrackFileSelected) {
      final file = currentState.file;

      emit(const AddTrackFileUploading(0.0));

      try {
        final updatedTrack = await projectsRepository.addTrackFile(
          projectId,
          trackId,
          file,
          onProgress: (sent, total) {
            emit(AddTrackFileUploading(sent / total));
          },
        );

        emit(AddTrackFileSuccess(updatedTrack));
      } catch (e) {
        emit(AddTrackFileFailure(e.toString()));
      }
    }
  }

  void reset() {
    emit(const AddTrackFileInitial());
  }
}