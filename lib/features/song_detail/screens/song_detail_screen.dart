import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/song_list_urls_cache_storage.dart';
import 'package:bandspace_mobile/features/song_detail/views/song_view.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/manage_songs_button.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class SongDetailScreen extends StatelessWidget {
  final Project project;

  const SongDetailScreen({super.key, required this.project});

  static Widget create(Project project, List<Song> songs, Song selectedSong) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SongDetailCubit(
            songListUrlsCacheStorage: context.read<SongListUrlsCacheStorage>(),
            projectsRepository: context.read<ProjectsRepository>(),
            projectId: project.id,
            songId: selectedSong.id,
            songs: songs,
            currentSong: selectedSong,
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
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ManageSongsButton(),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SongView(
        project: project,
      ),
    );
  }
}
