import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bandspace_mobile/core/utils/error_logger.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/delete_song/delete_song_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Cubit zarządzający procesem usuwania utworu
class DeleteSongCubit extends Cubit<DeleteSongState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final int songId;

  DeleteSongCubit({
    required this.projectsRepository,
    required this.projectId,
    required this.songId,
  }) : super(const DeleteSongInitial());

  /// Usuwa utwór z projektu
  Future<void> deleteSong() async {
    // Walidacja parametrów
    if (projectId <= 0 || songId <= 0) {
      emit(
        const DeleteSongFailure(
          message: 'Nieprawidłowe ID projektu lub utworu',
        ),
      );
      return;
    }

    try {
      emit(const DeleteSongLoading());

      // Wywołanie API do usunięcia utworu
      await projectsRepository.deleteSong(projectId, songId);

      emit(const DeleteSongSuccess());

      debugPrint('Song $songId deleted successfully from project $projectId');
    } catch (e, stackTrace) {
      logError(
        e,
        stackTrace: stackTrace,
        hint: 'Failed to delete song',
      );
      emit(
        DeleteSongFailure(
          message: e.toString(),
        ),
      );

      debugPrint('Failed to delete song $songId: $e');
    }
  }

  /// Resetuje stan do początkowego
  void reset() {
    emit(const DeleteSongInitial());
  }
}
