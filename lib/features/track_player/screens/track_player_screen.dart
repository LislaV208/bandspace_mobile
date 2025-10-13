import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_detail/cubit/track_detail_state.dart';
import 'package:bandspace_mobile/features/track_detail/widgets/manage_track_button.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_cache_repository.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_player_service.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_pre_caching_orchestrator.dart';
import 'package:bandspace_mobile/features/track_player/services/audio_source_factory.dart';
import 'package:bandspace_mobile/features/track_player/views/track_player_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackPlayerScreen extends StatelessWidget {
  final Project project;
  final List<Track> tracks;
  final Track initialTrack;

  const TrackPlayerScreen({
    super.key,
    required this.project,
    required this.tracks,
    required this.initialTrack,
  });

  // Helper method to create this screen
  static Widget create({
    required Project project,
    required List<Track> tracks,
    required Track initialTrack,
  }) {
    // Utwórz dependencies
    final dio = Dio();
    final cacheRepo = AudioCacheRepository(dio: dio, projectId: project.id);
    final sourceFactory = AudioSourceFactory(cacheRepo: cacheRepo);
    final playerService = AudioPlayerService(AudioPlayer());
    final preCachingOrchestrator = AudioPreCachingOrchestrator(
      cacheRepo: cacheRepo,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TrackPlayerCubit(
            playerService: playerService,
            sourceFactory: sourceFactory,
            preCachingOrchestrator: preCachingOrchestrator,
          )..initialize(tracks, initialTrack, project.id),
        ),
        BlocProvider(
          create: (context) => TrackDetailCubit(
            projectsRepository: context.read<ProjectsRepository>(),
            projectId: project.id,
            track: initialTrack,
          ),
        ),
      ],
      child: TrackPlayerScreen(
        project: project,
        tracks: tracks,
        initialTrack: initialTrack,
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

          if (trackDetailCubit.state.track.id != currentTrack.id) {
            trackDetailCubit.onTrackChanged(currentTrack);
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
                child: ManageTrackButton(),
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
