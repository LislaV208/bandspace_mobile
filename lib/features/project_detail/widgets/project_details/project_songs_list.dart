import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_song_list_item.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_songs_search.dart';

class ProjectSongsList extends StatelessWidget {
  final ProjectSongsReady state;

  const ProjectSongsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final songs = state is ProjectSongsFiltered
        ? (state as ProjectSongsFiltered).filteredSongs
        : state.songs;

    // Gdy brak utworów, używamy struktury podobnej do ProjectsList._buildEmptyState()
    if (songs.isEmpty) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: const ProjectSongsSearch(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<ProjectSongsCubit>().refreshSongs();
                },
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: state is ProjectSongsRefreshing ? 0.4 : 0,
                  child: Icon(Icons.refresh),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRefreshStatusContent(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 32, 0, 80),
                child: _buildEmptyState(context, state),
              ),
            ),
          ),
        ],
      );
    }

    // Gdy są utwory, używamy ListView
    return ListView(
      padding: const EdgeInsets.only(bottom: 56.0),
      children: [
        Row(
          children: [
            Expanded(
              child: const ProjectSongsSearch(),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                context.read<ProjectSongsCubit>().refreshSongs();
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: state is ProjectSongsRefreshing ? 0.4 : 0,
                child: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRefreshStatusContent(context),
        ...songs.map(
          (song) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ProjectSongListItem(
                songsList: state.songs,
                song: song,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRefreshStatusContent(BuildContext context) {
    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOut,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
      firstChild: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is ProjectSongsRefreshFailure
              ? ListTile(
                  dense: true,
                  title: Text(
                    'Brak połączenia z internetem',
                  ),
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  tileColor: Theme.of(context).colorScheme.errorContainer,
                  leading: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  subtitle: Text(
                    'Dane mogą być nieaktualne',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                    Text('Odświeżanie danych...'),
                  ],
                ),
        ),
      ),
      secondChild: Row(
        children: [],
      ),
      crossFadeState:
          state is ProjectSongsRefreshing || state is ProjectSongsRefreshFailure
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ProjectSongsReady state,
  ) {
    return state is ProjectSongsFiltered
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.searchX,
                color: Theme.of(context).colorScheme.tertiary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Brak utworów spełniających kryteria wyszukiwania',
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_off,
                size: 64,
                color: Theme.of(context).colorScheme.tertiary,
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
          );
  }
}
