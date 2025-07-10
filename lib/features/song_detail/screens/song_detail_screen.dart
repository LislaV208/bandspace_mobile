import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/views/song_files_view.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/manage_songs_button.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongDetailScreen extends StatelessWidget {
  final Project project;

  const SongDetailScreen({super.key, required this.project});

  static Widget create(Project project, Song song) {
    return BlocProvider(
      create: (context) => SongDetailCubit(
        projectsRepository: context.read<ProjectsRepository>(),
        projectId: project.id,
        songId: song.id,
        initialSong: song,
      ),
      child: SongDetailScreen(
        project: project,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongDetailCubit, SongDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                state.song.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                project.name,
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: ManageSongsButton(),
              ),
            ],
          ),
          body: BlocProvider(
            create: (context) => SongFilesCubit(
              projectsRepository: context.read<ProjectsRepository>(),
              projectId: project.id,
              songId: state.song.id,
            ),
            child: const SongFilesView(),
          ),
        );
      },
    );
  }
}
