import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';
import 'package:bandspace_mobile/shared/models/song_create_data.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający stanem tworzenia nowego utworu
class NewSongCubit extends Cubit<NewSongState> {
  final int projectId;
  final ProjectsRepository projectsRepository;

  NewSongCubit({
    required this.projectId,
    required this.projectsRepository,
  }) : super(const NewSongInitial());

  Future<void> selectFile() async {
    emit(const NewSongSelectingFile());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final songInitialName = file.path.split('/').last.split('.').first;
        emit(NewSongFileSelected(file: file, songInitialName: songInitialName));
      } else {
        emit(const NewSongInitial());
      }
    } catch (e) {
      emit(NewSongSelectFileFailure(e.toString()));
    }
  }

  void skipFileSelection() {
    emit(const NewSongFileSelected());
  }

  Future<void> uploadFile(CreateSongData songData) async {
    final currentState = state;
    
    if (currentState is NewSongFileSelected) {
      final songName = songData.title;

      emit(NewSongUploading(0.0, songName));

      try {
        if (currentState.file != null) {
          // Utwór z plikiem
          await projectsRepository.createSong(
            projectId,
            songData,
            currentState.file!,
            onProgress: (sent, total) {
              emit(NewSongUploading(sent / total, songName));
            },
          );
        } else {
          // Utwór bez pliku
          await projectsRepository.createSongWithoutFile(
            projectId,
            songData,
            onProgress: (sent, total) {
              emit(NewSongUploading(sent / total, songName));
            },
          );
        }

        emit(NewSongUploadSuccess(1.0, songName));
      } catch (e) {
        final progress = state is NewSongUploading
            ? (state as NewSongUploading).uploadProgress
            : 0.0;
        emit(NewSongUploadFailure(progress, songName, e.toString()));
      }
    }
  }

  void goToInitialStep() {
    emit(const NewSongInitial());
  }
}
