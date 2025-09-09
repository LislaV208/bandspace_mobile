import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/features/track_detail/widgets/manage_tracks_button.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/views/track_player_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackPlayerScreen extends StatelessWidget {
  final Project project;
  final List<Track> tracks;
  final int initialTrackId;

  const TrackPlayerScreen({
    super.key,
    required this.project,
    required this.tracks,
    required this.initialTrackId,
  });

  // Helper method to create this screen
  static Widget create({
    required Project project,
    required List<Track> tracks,
    required int initialTrackId,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              TrackPlayerCubit()
                ..loadTracksDirectly(tracks, initialTrackId, project.id),
        ),
        BlocProvider(
          create: (context) => TrackDetailCubit(
            projectsRepository: context.read<ProjectsRepository>(),
          ),
        ),
      ],
      child: TrackPlayerScreen(
        project: project,
        tracks: tracks,
        initialTrackId: initialTrackId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackPlayerCubit, TrackPlayerState>(
      listener: (context, playerState) {
        // Synchronizuj TrackDetailCubit z aktualną ścieżką z TrackPlayerCubit
        final currentTrack = playerState.currentTrack;
        if (currentTrack != null) {
          final trackDetailCubit = context.read<TrackDetailCubit>();
          // Inicjalizuj TrackDetailCubit z nową ścieżką tylko jeśli się zmieniła
          if (trackDetailCubit.state is! TrackDetailWithData ||
              (trackDetailCubit.state as TrackDetailWithData).track.id !=
                  currentTrack.id) {
            trackDetailCubit.initialize(currentTrack, project.id);
          }
        }
      },
      child: BlocListener<TrackDetailCubit, TrackDetailState>(
        listener: (context, detailState) {
          // Po pomyślnym usunięciu ścieżki, wróć do poprzedniego ekranu
          if (detailState is TrackDetailDeleteSuccess) {
            Navigator.of(context).pop();
          }
          // Po pomyślnej aktualizacji ścieżki, zaktualizuj TrackPlayerCubit
          else if (detailState is TrackDetailUpdateSuccess) {
            context.read<TrackPlayerCubit>().updateTrack(detailState.track);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: ManageTracksButton(),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          body: TrackPlayerView(
            project: project,
          ),
        ),
      ),
    );
  }
}
