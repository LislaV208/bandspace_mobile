import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/widgets/load_failure_view.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_songs_list.dart';

class ProjectDetailsView extends StatelessWidget {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<ProjectSongsCubit, ProjectSongsState>(
        builder: (context, state) {
          return switch (state) {
            ProjectSongsInitial() => const SizedBox(),
            ProjectSongsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProjectSongsReady() => ProjectSongsList(
              state: state,
            ),
            ProjectSongsLoadFailure() => LoadFailureView(
              title: 'Wystąpił błąd podczas ładowania utworów',
              errorMessage: state.message,
              onRetry: () => context.read<ProjectSongsCubit>().refreshSongs(),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
