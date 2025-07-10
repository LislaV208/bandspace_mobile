import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/edit_song/edit_song_state.dart';
import 'package:bandspace_mobile/shared/models/update_song_data.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający procesem edycji utworu
class EditSongCubit extends Cubit<EditSongState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  EditSongCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
  }) : super(const EditSongInitial());

  /// Aktualizuje utwór
  Future<void> updateSong(UpdateSongData updateData) async {
    try {
      emit(const EditSongLoading());

      // Wywołanie API do aktualizacji utworu
      await projectsRepository.updateSong(projectId, songId, updateData);

      await projectsRepository.refreshSongs(projectId);

      emit(const EditSongSuccess());
    } catch (e) {
      emit(
        EditSongFailure(
          message: e.toString(),
        ),
      );
    }
  }
}
