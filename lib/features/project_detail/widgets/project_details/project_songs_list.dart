import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_song_list_item.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class ProjectSongsList extends StatelessWidget {
  final List<Song> songs;

  const ProjectSongsList({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProjectSongsCubit>().refreshSongs();
      },
      displacement: 0.0,
      color: Theme.of(context).colorScheme.tertiary,
      child: songs.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.only(bottom: 56.0),
              children: songs.map(
                (project) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ProjectSongListItem(
                      song: project,
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.music,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Brak utworów w projekcie',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Dodaj pierwszy utwór, aby rozpocząć pracę',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
