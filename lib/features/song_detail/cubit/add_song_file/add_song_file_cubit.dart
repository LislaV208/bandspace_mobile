import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:bandspace_mobile/core/utils/error_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/add_song_file/add_song_file_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class AddSongFileCubit extends Cubit<AddSongFileState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  AddSongFileCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
  }) : super(const AddSongFileInitial());

  Future<void> selectFile() async {
    emit(const AddSongFileSelecting());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = file.path.split('/').last;
        emit(AddSongFileSelected(file, fileName));
      } else {
        emit(const AddSongFileInitial());
      }
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to select audio file for song',
      );
      emit(AddSongFileFailure(e.toString()));
    }
  }

  Future<void> uploadFile() async {
    final currentState = state;
    if (currentState is AddSongFileSelected) {
      final file = currentState.file;

      emit(const AddSongFileUploading(0.0));

      try {
        final updatedSong = await projectsRepository.addSongFile(
          projectId,
          songId,
          file,
          onProgress: (sent, total) {
            emit(AddSongFileUploading(sent / total));
          },
        );

        emit(AddSongFileSuccess(updatedSong));
      } catch (e, stackTrace) {
        logError(
          e,
          stackTrace: stackTrace,
          hint: 'Failed to upload song file',
        );
        emit(AddSongFileFailure(e.toString()));
      }
    }
  }

  void reset() {
    emit(const AddSongFileInitial());
  }
}