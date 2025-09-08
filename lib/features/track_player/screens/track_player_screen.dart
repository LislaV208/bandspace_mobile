import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/views/track_player_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

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
    return BlocProvider(
      create: (context) =>
          TrackPlayerCubit()
            ..loadTracksDirectly(tracks, initialTrackId, project.id),
      child: TrackPlayerScreen(
        project: project,
        tracks: tracks,
        initialTrackId: initialTrackId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            // child: ManageSongsButton(),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: TrackPlayerView(
        project: project,
      ),
    );
  }
}
