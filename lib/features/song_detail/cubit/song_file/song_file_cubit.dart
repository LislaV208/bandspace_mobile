import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_file/song_file_state.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongFileCubit extends Cubit<SongFileState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  SongFileCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
  }) : super(const SongFileInitial()) {
    loadSongFile();
  }

  late StreamSubscription<SongFile?> _fileSubscription;

  @override
  Future<void> close() {
    _fileSubscription.cancel();
    return super.close();
  }

  Future<void> loadSongFile() async {
    emit(const SongFileLoading());

    _fileSubscription = projectsRepository.getSongFile(projectId, songId).listen(
      (file) {
        print('SongFileCubit: Received file: $file'); // Debug log
        if (file != null) {
          emit(SongFileLoadSuccess(file));
        } else {
          emit(const SongFileEmpty());
        }
      },
      onError: (error) {
        print('SongFileCubit: Error loading file: $error'); // Debug log
        emit(SongFileLoadFailure(error.toString()));
      },
    );
  }

  Future<void> refreshSongFile() async {
    await projectsRepository.refreshSongFile(projectId, songId);
  }

  Future<void> loadFileUrl() async {
    if (state is SongFileLoadSuccess) {
      final currentState = state as SongFileLoadSuccess;
      
      try {
        final url = await projectsRepository.getSongFileDownloadUrl(
          projectId,
          songId,
        );

        emit(SongFileUrlLoaded(currentState.file, url));
      } catch (e) {
        emit(SongFileUrlLoadFailure(currentState.file, e.toString()));
      }
    }
  }
}