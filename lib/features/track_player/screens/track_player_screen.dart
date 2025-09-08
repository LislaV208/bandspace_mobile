import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/views/track_player_view.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackPlayerScreen extends StatelessWidget {
  final Project project;
  final int initialTrackId;

  const TrackPlayerScreen({
    super.key,
    required this.project,
    required this.initialTrackId,
  });

  // Helper method to create this screen
  static Widget create({
    required Project project,
    required int initialTrackId,
  }) {
    return BlocProvider(
      create: (context) => TrackPlayerCubit(
        projectsRepository: context.read<ProjectsRepository>(),
      )..loadProjectTracks(project.id, initialTrackId),
      child: TrackPlayerScreen(
        project: project,
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
