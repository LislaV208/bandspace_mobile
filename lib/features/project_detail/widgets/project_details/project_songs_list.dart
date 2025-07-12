import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_song_list_item.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_songs_search.dart';

class ProjectSongsList extends StatelessWidget {
  final ProjectSongsLoadSuccess state;

  const ProjectSongsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final songs = state is ProjectSongsFiltered
        ? (state as ProjectSongsFiltered).filteredSongs
        : state.songs;

    return Column(
      children: [
        if (songs.isNotEmpty) const ProjectSongsSearch(),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<ProjectSongsCubit>().refreshSongs();
            },
            displacement: 0.0,
            color: Theme.of(context).colorScheme.tertiary,
            child: songs.isEmpty
                ? _buildEmptyState(context, state)
                : ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ProjectSongListItem(
                          songsList: songs,
                          song: song,
                        ),
                      );
                    },
                    padding: const EdgeInsets.only(bottom: 56.0),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ProjectSongsLoadSuccess state,
  ) {
    if (state is ProjectSongsFiltered) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.searchX,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Brak utworów spełniających kryteria wyszukiwania',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
