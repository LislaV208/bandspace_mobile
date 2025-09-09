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
  })  : _projectsRepository = projectsRepository,
        super(const TrackDetailInitial());

  /// Inicjalizuje cubit z daną ścieżką i projektem
  void initialize(Track track, int projectId) {
    _projectId = projectId;
    emit(TrackDetailLoaded(track));
    
    // Nasłuchuj na zmiany ścieżki
    _subscribeToTrack(projectId, track.id);
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
              emit(TrackDetailLoaded(track));
            }
          },
          onError: (error) {
            emit(TrackDetailError('Failed to load track: ${error.toString()}'));
          },
        );
  }

  /// Aktualizuje ścieżkę
  Future<void> updateTrack(UpdateTrackData updateData) async {
    final currentTrack = _getCurrentTrack();
    if (currentTrack == null || _projectId == null) {
      emit(const TrackDetailError('Track or project not initialized'));
      return;
    }

    // Walidacja danych
    final validationError = updateData.validate();
    if (validationError != null) {
      emit(TrackDetailError(validationError));
      return;
    }

    if (!updateData.hasChanges) {
      emit(const TrackDetailError('No changes to save'));
      return;
    }

    emit(TrackDetailUpdating(currentTrack));

    try {
      final updatedTrack = await _projectsRepository.updateTrack(
        _projectId!,
        currentTrack.id,
        updateData,
      );

      emit(TrackDetailUpdateSuccess(updatedTrack));
    } catch (error) {
      emit(TrackDetailUpdateFailure(
        message: 'Failed to update track: ${error.toString()}',
        track: currentTrack,
      ));
    }
  }

  /// Usuwa ścieżkę
  Future<void> deleteTrack() async {
    final currentTrack = _getCurrentTrack();
    if (currentTrack == null || _projectId == null) {
      emit(const TrackDetailError('Track or project not initialized'));
      return;
    }

    emit(TrackDetailDeleting(currentTrack));

    try {
      await _projectsRepository.deleteTrack(_projectId!, currentTrack.id);
      emit(const TrackDetailDeleteSuccess());
    } catch (error) {
      emit(TrackDetailDeleteFailure(
        message: 'Failed to delete track: ${error.toString()}',
        track: currentTrack,
      ));
    }
  }

  /// Odświeża dane ścieżki z serwera
  Future<void> refreshTrack() async {
    final currentTrack = _getCurrentTrack();
    if (currentTrack == null || _projectId == null) {
      emit(const TrackDetailError('Track or project not initialized'));
      return;
    }

    emit(const TrackDetailLoading());

    try {
      await _projectsRepository.refreshTrack(_projectId!, currentTrack.id);
      // Nowy stan będzie emitowany przez stream subscription
    } catch (error) {
      emit(TrackDetailError('Failed to refresh track: ${error.toString()}'));
    }
  }

  /// Pobiera aktualną ścieżkę ze stanu
  Track? _getCurrentTrack() {
    final currentState = state;
    if (currentState is TrackDetailWithData) {
      return currentState.track;
    }
    return null;
  }

  @override
  Future<void> close() {
    _trackSubscription?.cancel();
    return super.close();
  }
}