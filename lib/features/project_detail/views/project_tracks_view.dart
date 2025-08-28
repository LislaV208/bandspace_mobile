import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/widgets/load_failure_view.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_tracks_list.dart';

class ProjectTracksView extends StatelessWidget {
  const ProjectTracksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<ProjectTracksCubit, ProjectTracksState>(
        builder: (context, state) {
          return switch (state) {
            ProjectTracksInitial() => const SizedBox(),
            ProjectTracksLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProjectTracksReady() => ProjectTracksList(
              state: state,
            ),
            ProjectTracksLoadFailure() => LoadFailureView(
              title: 'Wystąpił błąd podczas ładowania ścieżek',
              errorMessage: state.message,
              onRetry: () => context.read<ProjectTracksCubit>().refreshTracks(),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
