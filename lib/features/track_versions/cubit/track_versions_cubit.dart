import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/shared/models/version.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackVersionsCubit extends Cubit<TrackVersionsState> {
  final ProjectsRepository _repository;

  int? _projectId;
  int? _trackId;
  StreamSubscription<List<Version>>? _versionsSubscription;

  TrackVersionsCubit({
    required ProjectsRepository repository,
  })  : _repository = repository,
        super(const TrackVersionsInitial());

  void initialize({
    required int projectId,
    required int trackId,
  }) {
    _projectId = projectId;
    _trackId = trackId;
    loadVersions();
  }

  Future<void> loadVersions() async {
    if (_projectId == null || _trackId == null) {
      emit(const TrackVersionsError('Project ID or Track ID not initialized'));
      return;
    }

    emit(const TrackVersionsLoading());

    try {
      final response = await _repository.getTrackVersions(
        _projectId!,
        _trackId!,
      );

      _versionsSubscription?.cancel();
      _versionsSubscription = response.stream.listen(
        (versions) {
          if (state is! TrackVersionsRefreshing) {
            emit(TrackVersionsLoaded(versions));
          }
        },
        onError: (error) {
          emit(TrackVersionsError(error.toString()));
        },
      );
    } catch (error) {
      emit(TrackVersionsError(error.toString()));
    }
  }

  Future<void> refreshVersions() async {
    if (_projectId == null || _trackId == null) {
      emit(const TrackVersionsError('Project ID or Track ID not initialized'));
      return;
    }

    final currentState = state;
    if (currentState is TrackVersionsWithData) {
      emit(TrackVersionsRefreshing(currentState.versions));
    }

    try {
      await _repository.refreshTrackVersions(_projectId!, _trackId!);
      // Nowy stan będzie emitowany przez stream subscription
    } catch (error) {
      emit(TrackVersionsError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _versionsSubscription?.cancel();
    return super.close();
  }
}