import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_state.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class ProjectTracksCubit extends Cubit<ProjectTracksState> {
  final ProjectsRepository projectsRepository;
  final int projectId;
  final bool isNewlyCreated;

  ProjectTracksCubit({
    required this.projectsRepository,
    required this.projectId,
    this.isNewlyCreated = false,
  }) : super(const ProjectTracksInitial()) {
    loadTracks();
  }

  late StreamSubscription<List<Track>> _tracksSubscription;

  @override
  Future<void> close() {
    _tracksSubscription.cancel();

    return super.close();
  }

  Future<void> loadTracks() async {
    // Dla nowo utworzonych projektów od razu pokazuj pustą listę utworów
    if (isNewlyCreated) {
      emit(const ProjectTracksReady([]));
      
      // W tle i tak pobierz dane z serwera (na wypadek gdyby coś było)
      final response = await projectsRepository.getTracks(projectId);
      final stream = response.stream;
      
      _tracksSubscription =
          stream.listen((tracks) {
            // Jeśli jednak coś przyszło z serwera, zaktualizuj stan
            if (tracks.isNotEmpty) {
              emit(ProjectTracksReady(tracks));
            }
            log(tracks.toString());
          })..onError((error) {
            // Dla nowo utworzonych projektów ignoruj błędy ładowania
            log('Error loading tracks for newly created project: $error');
          });
      return;
    }

    // Standardowy przepływ dla istniejących projektów
    final response = await projectsRepository.getTracks(projectId);
    final cached = response.cached;
    final stream = response.stream;

    if (cached != null) {
      emit(ProjectTracksRefreshing(cached));
    } else {
      emit(const ProjectTracksLoading());
    }

    _tracksSubscription =
        stream.listen((tracks) async {
          await Future.delayed(const Duration(milliseconds: 500));

          emit(ProjectTracksReady(tracks));

          log(tracks.toString());
        })..onError((error) {
          final currentState = state;
          if (currentState is ProjectTracksReady) {
            emit(
              ProjectTracksRefreshFailure(currentState.tracks, error.toString()),
            );
          } else {
            emit(ProjectTracksLoadFailure(error.toString()));
          }
        });
  }

  Future<void> refreshTracks() async {
    final currentState = state;

    if (currentState is ProjectTracksRefreshing) return;

    if (currentState is ProjectTracksReady) {
      try {
        emit(ProjectTracksRefreshing(currentState.tracks));
        await Future.delayed(const Duration(milliseconds: 500));
        await projectsRepository.refreshTracks(projectId);
      } catch (e) {
        emit(ProjectTracksRefreshFailure(currentState.tracks, e.toString()));
      }
    } else if (currentState is ProjectTracksLoadFailure) {
      try {
        emit(const ProjectTracksLoading());
        await projectsRepository.refreshTracks(projectId);
      } catch (e) {
        emit(ProjectTracksLoadFailure(e.toString()));
      }
    }
  }

  Future<void> filterTracks(String query) async {
    if (state is! ProjectTracksReady) return;

    final originalTracks = (state as ProjectTracksReady).tracks;

    if (query.isEmpty) {
      if (state is! ProjectTracksFiltered) return;
      
      emit(ProjectTracksReady(originalTracks));
      return;
    }

    final filteredList = originalTracks
        .where((track) => track.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(ProjectTracksFiltered(originalTracks, filteredList));
  }
}
