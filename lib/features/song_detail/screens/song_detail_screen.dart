import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/views/song_view.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/manage_songs_button.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/widgets/load_failure_view.dart';

class SongDetailScreen extends StatelessWidget {
  final Project project;

  const SongDetailScreen({super.key, required this.project});

  static Widget create(Project project, Song song) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SongDetailCubit(
            projectsRepository: context.read<ProjectsRepository>(),
            projectId: project.id,
            songId: song.id,
            initialSong: song,
          ),
        ),
        BlocProvider(
          create: (context) => AudioPlayerCubit(),
        ),
      ],
      child: SongDetailScreen(
        project: project,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongDetailCubit, SongDetailState>(
      listener: (context, state) {
        if (state is SongFileUrlLoadSuccess) {
          context.read<AudioPlayerCubit>().loadUrl(state.url);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            // title: ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     state.song.title,
            //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //       color: Theme.of(context).colorScheme.onSurface,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            //   subtitle: Text(
            //     project.name,
            //   ),
            // ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: ManageSongsButton(),
              ),
            ],
          ),
          body: switch (state) {
            SongDetailInitial() => const SizedBox(),
            SongDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            SongDetailLoadFailure() => LoadFailureView(
              title: 'Wystąpił błąd podczas ładowania utworu',
              errorMessage: state.message,
              onRetry: () => context.read<SongDetailCubit>().refreshSongDetail(
                showLoading: true,
              ),
            ),
            SongDetailLoadSuccess() => SongView(
              project: project,
              state: state,
            ),
            _ => const SizedBox(),
          },
        );
      },
    );
  }
}
