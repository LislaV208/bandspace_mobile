import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/models/update_track_data.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackDetailCubit extends Cubit<TrackDetailState> {
  final ProjectsRepository _projectsRepository;

  int? _projectId;
  StreamSubscription<Track>? _trackSubscription;

  TrackDetailCubit({
    required ProjectsRepository projectsRepository,
    required int projectId,
    required Track track,
  }) : _projectsRepository = projectsRepository,
       super(TrackDetailLoaded(track)) {
    _projectId = projectId;

    // Nasłuchuj na zmiany ścieżki
    _subscribeToTrack(projectId, track.id);
  }

  void onTrackChanged(Track track) {
    emit(state.copyWith(track));
  }

  /// Subskrybuje zmiany dla konkretnej ścieżki
  void _subscribeToTrack(int projectId, int trackId) {
    _trackSubscription?.cancel();

    _trackSubscription = _projectsRepository
        .getTrack(projectId, trackId)
        .listen(
          (track) {
            // Emit TrackDetailLoaded jeśli nie jesteśmy w trakcie operacji
            if (state is! TrackDetailUpdating &&
                state is! TrackDetailDeleting) {
              emit(state.copyWith(track));
            }
          },
          onError: (error) {
            emit(TrackDetailError(error.toString(), state.track));
          },
        );
  }

  /// Aktualizuje ścieżkę
  Future<void> updateTrack(UpdateTrackData updateData) async {
    emit(TrackDetailUpdating(state.track));

    try {
      final updatedTrack = await _projectsRepository.updateTrack(
        _projectId!,
        state.track.id,
        updateData,
      );

      emit(TrackDetailUpdateSuccess(updatedTrack));
    } catch (error) {
      emit(
        TrackDetailUpdateFailure(
          message: error.toString(),
          track: state.track,
        ),
      );
    }
  }

  /// Usuwa ścieżkę
  Future<void> deleteTrack() async {
    emit(TrackDetailDeleting(state.track));

    try {
      await _projectsRepository.deleteTrack(_projectId!, state.track.id);
      emit(TrackDetailDeleteSuccess(state.track));
    } catch (error) {
      emit(
        TrackDetailDeleteFailure(
          error.toString(),
          state.track,
        ),
      );
    }
  }

  /// Pobiera ID projektu
  int? get projectId => _projectId;

  @override
  Future<void> close() {
    _trackSubscription?.cancel();
    return super.close();
  }
}
