import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_track_list_item.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_tracks_search.dart';

class ProjectTracksList extends StatelessWidget {
  final ProjectTracksReady state;

  const ProjectTracksList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tracks = state is ProjectTracksFiltered
        ? (state as ProjectTracksFiltered).filteredTracks
        : state.tracks;

    // Gdy brak ścieżek, używamy struktury podobnej do ProjectsList._buildEmptyState()
    if (tracks.isEmpty && state is! ProjectTracksFiltered) {
      return Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: ProjectTracksSearch(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<ProjectTracksCubit>().refreshTracks();
                },
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: state is ProjectTracksRefreshing ? 0.4 : 0,
                  child: const Icon(Icons.refresh),
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

    // Gdy są ścieżki, używamy ListView
    return ListView(
      padding: const EdgeInsets.only(bottom: 56.0),
      children: [
        Row(
          children: [
            const Expanded(
              child: ProjectTracksSearch(),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                context.read<ProjectTracksCubit>().refreshTracks();
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: state is ProjectTracksRefreshing ? 0.4 : 0,
                child: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRefreshStatusContent(context),
        if (tracks.isEmpty && state is ProjectTracksFiltered) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 80),
            child: _buildEmptyState(context, state),
          ),
        ] else ...[
          ...tracks.map(
            (track) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ProjectTrackListItem(
                  tracksList: state.tracks,
                  track: track,
                ),
              );
            },
          ),
        ],
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
          child: state is ProjectTracksRefreshFailure
              ? ListTile(
                  dense: true,
                  title: const Text(
                    'Brak połączenia z internetem',
                  ),
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  tileColor: Theme.of(context).colorScheme.errorContainer,
                  leading: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  subtitle: const Text(
                    'Dane mogą być nieaktualne',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // spacing: 12, // Row nie ma spacing
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Odświeżanie danych...'),
                  ],
                ),
        ),
      ),
      secondChild: const Row(
        children: [],
      ),
      crossFadeState:
          state is ProjectTracksRefreshing ||
              state is ProjectTracksRefreshFailure
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ProjectTracksReady state,
  ) {
    return state is ProjectTracksFiltered
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
              const Text(
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
              const Text(
                'Brak utworów w projekcie',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Dodaj pierwszy utwór, aby rozpocząć pracę',
                textAlign: TextAlign.center,
              ),
            ],
          );
  }
}
