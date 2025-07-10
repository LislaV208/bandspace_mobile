import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_state.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongFilesCubit extends Cubit<SongFilesState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  SongFilesCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
  }) : super(const SongFilesInitial()) {
    loadSongFiles();
  }

  late StreamSubscription<List<SongFile>> _filesSubscription;

  @override
  Future<void> close() {
    _filesSubscription.cancel();

    return super.close();
  }

  Future<void> loadSongFiles() async {
    emit(const SongFilesLoading());

    _filesSubscription =
        projectsRepository.getSongFiles(projectId, songId).listen((files) {
          emit(SongFilesLoadSuccess(files));
        })..onError((error) {
          emit(SongFilesLoadFailure(error.toString()));
        });
  }

  Future<void> refreshSongFiles() async {
    await projectsRepository.refreshSongFiles(projectId, songId);
  }
}
